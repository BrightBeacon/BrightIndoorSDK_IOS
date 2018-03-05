//
//  routeVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "RouteVC.h"
#import <AVFoundation/AVFoundation.h>

@interface RouteVC (){
	TYRouteResult *routeResult;
	TYRoutePart *currentRoutePart;
	BOOL isRouting;
}

@property(nonatomic,strong) TYLocalPoint *startLocalPoint;
@property(nonatomic,strong) TYLocalPoint *endLocalPoint;
@property(nonatomic,strong) TYLocalPoint *currentLocalPoint;

@property (nonatomic,strong) AVSpeechSynthesizer *speech;

@end

@implementation RouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonClicked:)];
}

- (void)dealloc {
    
}
//初始化路径图标
- (void)initSymbols
{
	AGSPictureMarkerSymbol *startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeStart"];
	startSymbol.offset = CGPointMake(0, 22);

	AGSPictureMarkerSymbol *endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeEnd"];
	endSymbol.offset = CGPointMake(0, 22);

	AGSPictureMarkerSymbol *switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeSwitch"];

	AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
	markerSymbol.size = CGSizeMake(5, 5);

	[self.mapView setRouteStartSymbol:startSymbol];
	[self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
}
- (void)initLocationSymbol {
    //设置地图显示定位图标
    AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
}
- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
	[self initSymbols];
    [self initLocationSymbol];
}

//自定义弹窗View
- (UIView *)customView:(TYPoi *)poi {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    titleLabel.text = [poi.name isEqual:[NSNull null]]?@"未知道路":poi.name;
	[view addSubview:titleLabel];


	UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 200, 25)];
	detailLabel.text = [NSString stringWithFormat:@"类别:%d",poi.categoryID];
	[view addSubview:detailLabel];

	UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 58, 80, 44)];
	[leftbtn setBackgroundColor:[UIColor redColor]];
	[leftbtn setTitle:@"起点" forState:UIControlStateNormal];
	[leftbtn addTarget:self action:@selector(startButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:leftbtn];

	UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(200-8-80, 58, 80, 44)];
	[rightbtn setBackgroundColor:[UIColor greenColor]];
	[rightbtn setTitle:@"终点" forState:UIControlStateNormal];
	[rightbtn addTarget:self action:@selector(endButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:rightbtn];
	return view;
}

- (void)requesRoute {
	if (self.startLocalPoint&&self.endLocalPoint) {
		[self.mapView.routeManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
	}
}

- (IBAction)startButtonClicked:(id)sender {
	self.startLocalPoint = self.currentLocalPoint;
	[self.mapView showRouteStartSymbolOnCurrentFloor:self.startLocalPoint];
	[self.mapView.callout dismiss];
	[self requesRoute];
}

- (IBAction)endButtonClicked:(id)sender {
	self.endLocalPoint = self.currentLocalPoint;
	[self.mapView showRouteEndSymbolOnCurrentFloor:self.endLocalPoint];
	[self.mapView.callout dismiss];
	[self requesRoute];
}

- (IBAction)clearButtonClicked:(id)sender {
    [self.mapView resetRouteLayer];
}
#pragma mark - **************** 地图回调

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    
    if (isRouting) {
        return;
    }
    
    TYPoi *poi = array.firstObject;
    AGSPoint *centerPt;
    if ([poi.geometry isKindOfClass:[AGSPolygon class]]) {
        centerPt = [[AGSGeometryEngine defaultGeometryEngine] labelPointForPolygon:(AGSPolygon *)poi.geometry];
    }else {
        centerPt = (AGSPoint *)poi.geometry;
    }
    mapView.callout.customView = [self customView:poi];
    self.currentLocalPoint = [TYLocalPoint pointWithX:centerPt.x Y:centerPt.y Floor:self.mapView.currentMapInfo.floorNumber];
    [mapView.callout showCalloutAt:centerPt screenOffset:CGPointZero animated:YES];
}

- (BOOL)isEnd:(TYLocalPoint *)lp {
    double distance2end = [routeResult distanceToRouteEnd:lp];
    //约5米左右到达目的地附近
    if (distance2end < 5) {
        [self.mapView resetRouteLayer];
        isRouting = NO;
        self.startLocalPoint = nil;
        self.endLocalPoint = nil;
        self.currentLocalPoint = nil;
        [self textToSpeech:@"已到达终点5米附近。"];
        return YES;
    }
    return NO;
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    if (isRouting) {
        //构造点击地图，模拟定位点location
        TYLocalPoint *location = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber];
        TYRoutePart *part = [routeResult getNearestRoutePart:location];
        [self.mapView showLocation:location];
        
        //本层无路网
        if (!part) {
            return;
        }
        
        //是否到达终点
        if ([self isEnd:location]) {
            return;
        }

        //是否偏航
		if ([routeResult isDeviatingFromRoute:location WithThrehold:5]) {
			//模拟偏航5米，重新规划路径
			self.currentLocalPoint = location;
            [self startButtonClicked:nil];
            [self textToSpeech:@"你已偏航5米，重新规划路线。"];
            return;
        }
        //显示路过和余下线段
        [mapView showPassedAndRemainingRouteResultOnCurrentFloor:location];

        //导航中，可以把定位点吸附到最近的路径上的点
        location = [routeResult getNearPointOnRoute:location];
        [self.mapView showLocation:location];
        
        //获取整条路径所有导航提示，参数说明：忽略3米以内短路段，15度小角度提示；可以按需调整规避频繁提示
        NSArray *routeGuides = [routeResult getRouteDirectionalHint:part distanceThrehold:3 angleThrehold:15];
        if (routeGuides.count) {
            TYDirectionalHint *hint = [routeResult getDirectionHintForLocation:location FromHints:routeGuides];
            
            //手动处理，居中和旋转地图角度，或是否高亮路段。
            //[self.mapView centerAtPoint:mappoint animated:NO];
            //[self.mapView setRotationAngle:hint.currentAngle aroundMapPoint:mappoint animated:YES];
            //[self.mapView showRouteHintForDirectionHint:hint Centered:NO];
            
            //自动处理地图角度：
            //TYMapViewModeDefault地图方向不变，定位图标旋转
            //TYMapViewModeFollowing地图方向旋转，定位图标保持前方
            [self.mapView setMapMode:TYMapViewModeFollowing];
            [self.mapView processDeviceRotation:hint.currentAngle];
            
            //计算当前定位点所在段，定位点距离两端直线距离。
            //段前10米或1/5提示：本段方向
            //段中间提示：沿路前行
            //段后15米或1/3提示：下一段路径方向
            float len2Start = [location distanceWith:(TYLocalPoint*)hint.startPoint];
            float len2End = [location distanceWith:(TYLocalPoint*)hint.endPoint];
            if (len2Start<MIN(hint.length/5.0, 10)) {
                [self textToSpeech:[hint getDirectionString]];
            }else if(len2End<MIN(hint.length/3.0, 15)){
                if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%.0f米%@",len2End,[hint.nextHint getDirectionString]]];
                else [self textToSpeech:@"请保持前行"];
            }else{
                [self textToSpeech:[NSString stringWithFormat:@"沿路前行%.0f米",len2End]];
            }
        }
	}
}

- (AVSpeechSynthesizer *)speech {
    if (!_speech) {
        _speech = [[AVSpeechSynthesizer alloc] init];
    }
    return _speech;
}
  //TTS 文本合成语音
- (IBAction)textToSpeech:(NSString *)text
{
    [self.speech stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer < 9) {
        utterance.rate = 0.15;
    }else if(sysVer == 9){
        utterance.rate = 0.53;
    }else{
        utterance.rate = 0.5;
    }
    [self.speech speakUtterance:utterance];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    [super TYMapView:mapView didFinishLoadingFloor:mapInfo];
	//显示当前楼层导航信息
	if (isRouting) {
		[self.mapView showRouteResultOnCurrentFloor];
	}
}
#pragma mark - **************** 路径规划
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"没有找到路线" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    [self.mapView resetRouteLayer];
    self.startLocalPoint = nil;
    self.endLocalPoint = nil;
    isRouting = NO;
	NSLog(@"%@", error);
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
	routeResult = rs;
	isRouting = YES;

	[self.mapView setRouteResult:rs];
	[self.mapView setRouteStart:self.startLocalPoint];
	[self.mapView setRouteEnd:self.endLocalPoint];
	[self.mapView showRouteResultOnCurrentFloor];

	//获取当前楼层路段
	NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.mapView.currentMapInfo.floorNumber];
    currentRoutePart = routePartArray.firstObject;

	//缩放到路段
	if (currentRoutePart) {
//		[self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:80 animated:YES];
	}
}

@end
