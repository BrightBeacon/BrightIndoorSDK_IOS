//
//  ViewController.m
//  mapdemo
//
//  Created by thomasho on 16/5/20.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "ViewController.h"
#import <TYLocationEngine/TYLocationEngine.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<TYMapViewDelegate,TYOfflineRouteManagerDelegate,AGSCalloutDelegate,TYLocationManagerDelegate,UISearchBarDelegate>{
    BOOL isRouting;
    BOOL isFirstlocation;
    
    // 路径规划结果
    TYRouteResult *routeResult;
    TYRoutePart *currentRoutePart;
	IBOutlet UILabel *hintLabel;
    
    AGSGraphicsLayer *hintLayer;
    
    // 起点、终点、切换点标识符号
    AGSPictureMarkerSymbol *startSymbol;
    AGSPictureMarkerSymbol *endSymbol;
    AGSPictureMarkerSymbol *switchSymbol;
    AGSSimpleMarkerSymbol *markerSymbol;
    AGSPictureMarkerSymbol *locationSymbol;
}

@property(nonatomic,strong) TYLocalPoint *startLocalPoint;
@property(nonatomic,strong) TYLocalPoint *endLocalPoint;
@property(nonatomic,strong) TYLocalPoint *currentLocalPoint;
@property(nonatomic,strong) TYLocalPoint *lastLocalPoint;


@property (nonatomic,strong) AVSpeechSynthesizer *speech;
//定位管理器
@property (nonatomic,strong) TYLocationManager *loc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstlocation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.loc stopUpdateLocation];
	self.loc = nil;
}

- (void)showLocationControl {
    CGRect frame = CGRectMake(20, self.view.bounds.size.height - 120, 40, 40);
    UIButton *locbtn = [[UIButton alloc] initWithFrame:frame];
    [locbtn setImage:[UIImage imageNamed:@"locbutton"] forState:UIControlStateNormal];
    [locbtn addTarget:self action:@selector(locButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locbtn];
}

#pragma mark - loadMapView

- (void)loadMapView {
    [self showLocationControl];
    //初始化地图标识
    [self initSymbols];
    
    //点击地图出现小圆点图层
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    //设置地图导航旋转模式
    [self.mapView setMapMode:TYMapViewModeFollowing];
    //设置地图选中高亮（本例已在TYMapView:PoiSelected回调中高亮Poi）
    //    [self.mapView setHighlightPOIOnSelection:YES];
    //设置地图弹窗
    self.mapView.callout.delegate = self;
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    [self loadMapView];
}

- (AVSpeechSynthesizer *)speech {
    if (!_speech) {
        _speech = [[AVSpeechSynthesizer alloc] init];
    }
    return _speech;
}
- (IBAction)textToSpeech:(NSString *)text
{
    [self.speech stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:text];  //需要转换的文本
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer < 9) {
        utterance.rate = 0.15;
    }else if(sysVer == 9){
        utterance.rate = 0.53;
    }else{
        utterance.rate = 0.5;
    }
//    utterance.pitchMultiplier = 2;
    [self.speech speakUtterance:utterance];
}

#pragma mark - **************** 定位回调

- (void)TYLocationManager:(TYLocationManager *)manager didFailUpdateLocation:(NSError *)error {

}

- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation{
    if (isFirstlocation) {
        isFirstlocation = NO;
        AGSPoint *pt = [AGSPoint pointWithX:newLocation.x y:newLocation.y spatialReference:self.mapView.spatialReference];
        [self.mapView centerAtPoint:pt animated:YES];
    }
    self.startLocalPoint = newLocation;
    self.currentLocalPoint = newLocation;

    // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
    if (self.mapView.currentMapInfo.floorNumber!=newLocation.floor) {
        [self.mapView setFloor:[NSString stringWithFormat:@"%d",newLocation.floor]];
        return;
    }
    TYLocalPoint *localPoint = newLocation;
    if (isRouting) {
        double distance2end = [self.endLocalPoint distanceWith:localPoint];
        if (distance2end<2) {
            [self.mapView resetRouteLayer];
            isRouting = NO;
            [self.mapView showLocation:localPoint];
            self.startLocalPoint = nil;
            self.endLocalPoint = nil;
            self.currentLocalPoint = nil;
            [self textToSpeech:@"已到达终点附近。"];
            NSLog(@"已到达终点附近。");
            return;
        }
        if ([routeResult isDeviatingFromRoute:localPoint WithThrehold:2]) {
            //偏航2米，重新规划路径
            self.startLocalPoint = localPoint;
            [self requestRoute];
            [self textToSpeech:@"你已偏航，重新规划路线。"];
            [self.mapView showLocation:localPoint];
            return;
        }
        //显示路过和余下线段
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:localPoint];

        //导航中，未偏航，可以直接吸附到最近的路径上。注意：同层如有隔断，会出现多路径线段TYRoutePart
        AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
        TYRoutePart *part = [routeResult getNearestRoutePart:localPoint];
        if (part) {
            AGSProximityResult *result = [engine nearestCoordinateInGeometry:part.route toPoint:[AGSPoint pointWithX:newLocation.x y:newLocation.y spatialReference:self.mapView.spatialReference]];

            localPoint = [TYLocalPoint pointWithX:result.point.x Y:result.point.y Floor:self.mapView.currentMapInfo.floorNumber];
        //移动位置超过2米，进行导航提示
        NSArray *routeGuides = [routeResult getRouteDirectionalHint:part];
        if (routeGuides.count&&[localPoint distanceWith:self.lastLocalPoint]>2) {
            self.lastLocalPoint = localPoint;
            //地图显示本线段
            TYDirectionalHint *hint = [routeResult getDirectionHintForLocation:localPoint FromHints:routeGuides];
            if (![hint.routePart.route.envelope containsPoint:result.point]) {
                //点不在线段上
                return;
            }
            [self.mapView showRouteHintForDirectionHint:hint Centered:NO];
            //计算当前位置点，距离本路段起点、终点距离
            float len2Start = [localPoint distanceWith:(TYLocalPoint*)hint.startPoint];
            float len2End = [localPoint distanceWith:(TYLocalPoint*)hint.endPoint];
            //当前路段开始2米、或1/5以内提示本段方向
            if (len2Start<MIN(hint.length/5.0, 2)) {
                [self textToSpeech:[hint getDirectionString]];
            }else if(len2End<MIN(hint.length/3.0, 10)){
                //当前路段末尾10米、或最后1/3以内提示下一段方向（有可能无提示）
                if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%.0f米%@",len2End,[hint.nextHint getDirectionString]]];
                else [self textToSpeech:@"请保持直行"];
            }else{
                //中间路段，含微小弯道或直行部分
                [self textToSpeech:[NSString stringWithFormat:@"继续沿路前行%.0f米",len2End]];
            }
        }
        }
    }
    [self.mapView showLocation:localPoint];
}
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateImmediateLocation:(TYLocalPoint *)newImmediateLocation{
    
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedBeacons:(NSArray *)beacons{
    
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons{
    for (TYBeacon *b in beacons) {
        NSLog(@"%@_%d",b.minor,b.rssi);
    }
}
- (void)updateDeviceHeading:(double)heading initAngle:(int)angle mapViewMode:(int)mode {
    NSLog(@"%f_%d_%d",heading,angle,mode);
}
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateDeviceHeading:(double)newHeading {
    //处理地图旋转，依据设置的旋转模式
    [self.mapView processDeviceRotation:newHeading];
}
#pragma mark - **************** 路径规划
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    //移除其他图层显示
    [hintLayer removeAllGraphics];
    
    routeResult = rs;
    
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:self.startLocalPoint];
    [self.mapView setRouteEnd:self.endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.mapView.currentMapInfo.floorNumber];
    if (routePartArray && routePartArray.count > 0) {
        currentRoutePart = [routePartArray objectAtIndex:0];
    }
    
    if (currentRoutePart) {
        [self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:80 animated:YES];
    }
    //    [self.mapView setMapMode:TYMapViewModeFollowing];
}

#pragma mark - **************** 地图回调

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}
- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    TYPoi *poi = array.firstObject;
    if (poi) {
        [mapView highlightPoi:poi];
        //        AGSPoint *location = nil;
        //        if ([poi.geometry isKindOfClass:[AGSPolygon class]]) {
        //            location = [[AGSGeometryEngine defaultGeometryEngine] labelPointForPolygon:(AGSPolygon *)poi.geometry];
        //        }else{
        //            location = (AGSPoint *)poi.geometry;
        //        }
        //        mapView.callout.delegate = self;
        //        mapView.callout.title = poi.name;
        //        mapView.callout.detail = poi.poiID;
        //        [mapView.callout showCalloutAt:location screenOffset:CGPointZero animated:YES];
    }
}
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    [self.view endEditing:YES];
    //显示当前点击位置(AGSGraphicsLayer *)mapView.baseLayer
    if ([mapView.baseLayer.fullEnvelope containsPoint:mappoint]) {
        [hintLayer removeAllGraphics];
        [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    }
    self.mapView.callout.customView = [self calloutView:mappoint];
    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointMake(0, 0) animated:YES];
}

- (UIView *)calloutView:(AGSPoint *)point {
    TYPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:point.x Y:point.y];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 160, 25)];
    titleLabel.text = [poi.name isEqual:[NSNull null]]?@"无名位置":poi.name;
    [view addSubview:titleLabel];


    UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 58, 80, 34)];
    [leftbtn setBackgroundColor:[UIColor greenColor]];
    [leftbtn setTitle:@"起点" forState:UIControlStateNormal];
    leftbtn.layer.cornerRadius = 17;
    leftbtn.tag = 1;
    [leftbtn addTarget:self action:@selector(calloutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:leftbtn];

    UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(200-8-80, 58, 80, 34)];
    [rightbtn setBackgroundColor:[UIColor redColor]];
    [rightbtn setTitle:@"终点" forState:UIControlStateNormal];
    rightbtn.layer.cornerRadius = 17;
    [rightbtn setTitle:poi.poiID forState:UIControlStateApplication];
    [rightbtn addTarget:self action:@selector(calloutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:rightbtn];
    return view;
}

#pragma mark - **************** 配置默认弹出样式（可以自定义customView）

- (IBAction)calloutButtonClicked:(UIButton *)sender {
    AGSPoint *mapLocation = self.mapView.callout.mapLocation;
    if (sender.tag == 0) {
        self.endLocalPoint = [TYLocalPoint pointWithX:mapLocation.x Y:mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];
    }else{
        self.startLocalPoint = [TYLocalPoint pointWithX:mapLocation.x Y:mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];;
    }
    [self.mapView.callout dismiss];
    [self requestRoute];
}

#pragma mark - **************** methods

- (void)requestRoute
{
    if (self.startLocalPoint == nil || self.endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    [self.mapView.routeManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeStart"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeEnd"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeSwitch"];
    
    markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
    
    
    AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
}
#pragma mark - Actions

- (IBAction)locButtonClicked:(id)sender {
    if (_loc == nil) {
        //定位初始化
        NSString *path = [TYMapEnvironment getRootDirectoryForMapFiles];
        [TYBLEEnvironment setRootDirectoryForFiles:path];
        self.loc = [[TYLocationManager alloc] initWithBuilding:kBuildingId appKey:kAppKey];
        [_loc setRssiThreshold:-100];
        [_loc setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"] identifier:@"identifier1"]];
        _loc.delegate = self;
    }
    [_loc startUpdateLocation];
	if(self.currentLocalPoint)[self.mapView zoomToResolution:30/[UIScreen mainScreen].bounds.size.width withCenterPoint:[AGSPoint pointWithX:self.currentLocalPoint.x y:self.currentLocalPoint.y spatialReference:self.mapView.spatialReference] animated:YES];
    if (isRouting) {
        double len = 0;
        for (TYRoutePart *rp in routeResult.allRoutePartArray) {
            len += [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:rp.getFirstPoint toGeometry:rp.getLastPoint];
        }
        int min = ceil(len/80);
        [self textToSpeech:[NSString stringWithFormat:@"开始导航，全程%.0f米，大约需要%d分钟",len,min]];
    }
}
- (IBAction)cancelButtonClicked:(id)sender {
    [_loc stopUpdateLocation];
    self.currentLocalPoint = nil;
    [self.mapView removeLocation];
    
    [self.mapView resetRouteLayer];
    self.startLocalPoint = nil;
    self.endLocalPoint = nil;
    [self.view endEditing:YES];
}

#pragma mark - SearchDelgate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        //to do
        
        TYPoi *poi = [self.mapView getPoiOnCurrentFloorWithPoiID:searchBar.text layer:POI_ROOM];
        if (poi&&poi.categoryID!=800&&poi.categoryID!=300) {
            [self.mapView highlightPoi:poi];
        }
    }
}
@end
