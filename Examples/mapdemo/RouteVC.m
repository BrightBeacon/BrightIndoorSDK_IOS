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
    // Do any additional setup after loading the view.
}
//初始化路径图标
- (void)initSymbols
{
	AGSPictureMarkerSymbol *startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
	startSymbol.offset = CGPointMake(0, 22);

	AGSPictureMarkerSymbol *endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
	endSymbol.offset = CGPointMake(0, 22);

	AGSPictureMarkerSymbol *switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];

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
	[self initSymbols];
    [self initLocationSymbol];
}

//自定义View
- (UIView *)customView:(AGSPoint *)pt {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
	titleLabel.text = @"提示";
	[view addSubview:titleLabel];


	UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 200, 25)];
	detailLabel.text = [NSString stringWithFormat:@"位置:%f,%f",pt.x,pt.y];
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
	self.currentLocalPoint = [TYLocalPoint pointWithX:pt.x Y:pt.y Floor:self.mapView.currentMapInfo.floorNumber];
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

#pragma mark - **************** 地图回调

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    if (isRouting) {
        TYLocalPoint *localPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber];
        double distance2end = [self.endLocalPoint distanceWith:localPoint];
        if (distance2end<2) {
            [mapView resetRouteLayer];
            isRouting = NO;
            [mapView showLocation:localPoint];
            self.startLocalPoint = nil;
            self.endLocalPoint = nil;
            self.currentLocalPoint = nil;
            [self textToSpeech:@"已到达终点附近。"];
            NSLog(@"已到达终点附近。");
            return;
        }

		if ([routeResult isDeviatingFromRoute:localPoint WithThrehold:2]) {
			//模拟偏航2米，重新规划路径
			self.currentLocalPoint = localPoint;
            [self startButtonClicked:nil];
            [self textToSpeech:@"你已偏航，重新规划路线。"];
            //模拟定位点，显示导航路径
            [mapView showLocation:localPoint];
            return;
        }
        //显示路过和余下线段
        [mapView showPassedAndRemainingRouteResultOnCurrentFloor:localPoint];

        //导航中，未偏航，可以直接吸附到最近的路径上。注意：同层如有隔断，会出现多路径线段TYRoutePart
        AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
        TYRoutePart *part = [routeResult getNearestRoutePart:localPoint];
        if (part) {
            AGSProximityResult *result = [engine nearestCoordinateInGeometry:part.route toPoint:mappoint];
            mappoint = result.point;
            localPoint = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber];
        }
        //导航提示
        NSArray *routeGuides = [routeResult getRouteDirectionalHint:part];
        if (routeGuides.count) {
            TYDirectionalHint *hint = [routeResult getDirectionHintForLocation:localPoint FromHints:routeGuides];
//            [self.mapView showRouteHintForDirectionHint:hint Centered:NO];
            float len2Start = [localPoint distanceWith:(TYLocalPoint*)hint.startPoint];
            float len2End = [localPoint distanceWith:(TYLocalPoint*)hint.endPoint];
            if (len2Start<MIN(hint.length/5.0, 2)) {
                [self textToSpeech:[hint getDirectionString]];
            }else if(len2End<MIN(hint.length/3.0, 10)){
                if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%.0f米%@",len2End,[hint.nextHint getDirectionString]]];
                else [self textToSpeech:@"请保持直行"];
            }else{
                [self textToSpeech:[NSString stringWithFormat:@"请沿当前路线前行%.0f米",len2End]];
            }
        }
		//模拟定位点，显示导航路径
		[mapView showLocation:localPoint];
		return;
	}
    if ([self.mapView.baseLayer.fullEnvelope containsPoint:mappoint]) {
        mapView.callout.customView = [self customView:mappoint];
        [mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
    }else{
        NSLog(@"未在有效范围");
    }
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

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
	//显示当前楼层导航信息
	if (isRouting) {
		[self.mapView showRouteResultOnCurrentFloor];
	}
}
#pragma mark - **************** 路径规划
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
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
		[self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:80 animated:YES];
	}
}

@end
