//
//  ViewController.m
//  mapdemo
//
//  Created by thomasho on 16/5/20.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocationDemoVC.h"
#import <TYLocationEngine/TYLocationEngine.h>
#import <AVFoundation/AVFoundation.h>
#import <TYTileMapSDK/TYTileMapSDK.h>

@interface LocationDemoVC ()<TYMapViewDelegate,TYOfflineRouteManagerDelegate,AGSCalloutDelegate,TYLocationManagerDelegate,UISearchBarDelegate>{
    BOOL isRouting;
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
    
    TYTiledManager *tileManager;
    
}

@property(nonatomic,strong) TYLocalPoint *startLocalPoint;
@property(nonatomic,strong) TYLocalPoint *endLocalPoint;
@property(nonatomic,strong) TYLocalPoint *currentLocalPoint;
@property(nonatomic,strong) TYLocalPoint *lastLocalPoint;

//语音合成器
@property (nonatomic,strong) AVSpeechSynthesizer *speech;
//定位管理器
@property (nonatomic,strong) TYLocationManager *loc;
@end

@implementation LocationDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tileManager = [[TYTiledManager alloc] initWithBuilding:kBuildingId];
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
    
    //设置地图导航旋转模式(默认旋转定位图标)
    [self.mapView setMapMode:TYMapViewModeDefault];
    
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
    NSLog(@"%f",locationSymbol.angle);
    if (isnan(newLocation.x)) {
        return;
    }
    if (manager.getLastLocation == nil) {
        AGSPoint *pt = [AGSPoint pointWithX:newLocation.x y:newLocation.y spatialReference:self.mapView.spatialReference];
        [self.mapView centerAtPoint:pt animated:YES];
    }
    self.startLocalPoint = newLocation;
    self.currentLocalPoint = newLocation;

    // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
    if (self.mapView.currentMapInfo.floorNumber!=newLocation.floor) {
        [self.mapView setFloor:[NSString stringWithFormat:@"%d",newLocation.floor]];
        [self.mapView showLocation:newLocation];
        return;
    }
    TYLocalPoint *localPoint = newLocation;
    if (isRouting) {
        double distance2end = [routeResult distanceToRouteEnd:localPoint];
        if (distance2end<5) {
            [self.mapView resetRouteLayer];
            isRouting = NO;
            [self.mapView showLocation:localPoint];
            self.startLocalPoint = nil;
            self.endLocalPoint = nil;
            self.currentLocalPoint = nil;
            [self textToSpeech:@"已到达终点5米附近。"];
            return;
        }
        if ([routeResult isDeviatingFromRoute:localPoint WithThrehold:5]) {
            //偏航5米，重新规划路径
            self.startLocalPoint = localPoint;
            [self requestRoute];
            [self textToSpeech:@"你已偏航5米，重新规划路线。"];
            [self.mapView showLocation:localPoint];
            return;
        }
        //显示路过和余下线段
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:localPoint];

        //导航中，未偏航，可以直接吸附到最近的路径上。注意：同层如有全隔断，会出现多路径线段TYRoutePart
        TYRoutePart *part = [routeResult getNearestRoutePart:localPoint];
        if (part) {
            localPoint = [routeResult getNearPointOnRoute:localPoint];
        //移动位置超过2米，进行导航提示
        NSArray *routeGuides = [routeResult getRouteDirectionalHint:part distanceThrehold:0 angleThrehold:10];
        if (routeGuides.count&&[localPoint distanceWith:self.lastLocalPoint]>2) {
            self.lastLocalPoint = localPoint;
            //地图显示本线段
            TYDirectionalHint *hint = [routeResult getDirectionHintForLocation:localPoint FromHints:routeGuides];
            [self.mapView showRouteHintForDirectionHint:hint Centered:YES];
//            self.mapView.rotationAngle = hint.currentAngle;
//            [self.mapView centerAtPoint:pt animated:YES];
            //计算当前位置点，距离本段起点、终点距离
            if (hint.length <= 5) {
                if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%@",[hint.nextHint getDirectionString]]];
                else [self textToSpeech:@"请沿路前行"];
            }else {
                float len2Start = [localPoint distanceWith:(TYLocalPoint*)hint.startPoint];
                float len2End = [localPoint distanceWith:(TYLocalPoint*)hint.endPoint];
                if (len2Start<MIN(hint.length/10.0, 5)) {
                    //当前路段开始5米、或1/5以内提示本段方向
                    [self textToSpeech:[hint getDirectionString]];
                }else if(len2End<MIN(hint.length/2.0, 10)){
                    //当前路段末尾10米、或最后1/3以内提示下一段方向（有可能无提示）
                    if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%.0f米%@",len2End,[hint.nextHint getDirectionString]]];
                    else [self textToSpeech:@"请沿路前行"];
                }else{
                    //当前路段中间，或含微小弯道或直行部分
                    [self textToSpeech:[NSString stringWithFormat:@"继续沿路前行%.0f米",len2End]];
                }
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
//    for (TYBeacon *b in beacons) {
//        NSLog(@"%@_%d",b.minor,b.rssi);
//    }
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
        [self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:100 animated:YES];
    }
        [self.mapView setMapMode:TYMapViewModeFollowing];
}

#pragma mark - **************** 地图回调

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    [super TYMapView:mapView didFinishLoadingFloor:mapInfo];
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
    TYTiledLayer *tileLayer = (TYTiledLayer *)[mapView mapLayerForName:@"layerid"];
    [mapView removeMapLayer:tileLayer];
    
    NSString *dir = [TYMapEnvironment getRootDirectoryForMapFiles];
    tileLayer = [[TYTiledLayer alloc] initWithTileRoot:dir withTileInfo:[tileManager tileInfoByFloor:mapInfo.floorName]];
    //必要时清空缓存瓦片，默认使用本地缓存瓦片
    //[tileLayer removeTileCache];
    if(tileLayer&&!tileLayer.error){
        [mapView insertMapLayer:tileLayer withName:@"layerid" atIndex:0];
        AGSPoint *center = tileLayer.fullEnvelope.center;
        [mapView centerAtPoint:center animated:YES];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    [self.view endEditing:YES];
    //显示当前点击位置(AGSGraphicsLayer *)mapView.baseLayer
    if ([mapView.baseLayer.fullEnvelope containsPoint:mappoint]) {
        [hintLayer removeAllGraphics];
        [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
        self.mapView.callout.customView = [self calloutView:mappoint];
        [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointMake(0, 0) animated:YES];
    }
    
    [self TYLocationManager:_loc didUpdateLocation:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber]];
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
        //所有设备rssi低于此值，则不进行定位
        [_loc setRssiThreshold:-70];
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

@end
