//
//  routeVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "RouteVC.h"

@interface RouteVC (){
	TYRouteResult *routeResult;
	TYRoutePart *currentRoutePart;
	NSArray *routeGuides;
	BOOL isRouting;
}

@property(nonatomic,strong) TYLocalPoint *startLocalPoint;
@property(nonatomic,strong) TYLocalPoint *endLocalPoint;
@property(nonatomic,strong) TYLocalPoint *currentLocalPoint;

@end

@implementation RouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
- (void)TYMapViewDidLoad:(TYMapView *)mapView {
	[self initSymbols];
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
		[self.routeManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
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
		if ([routeResult isDeviatingFromRoute:localPoint WithThrehold:2]) {
			//模拟偏航2米，重新规划路径
			self.currentLocalPoint = localPoint;
			[self startButtonClicked:nil];
		}
		//模拟定位点，显示导航路径
		[mapView showLocation:localPoint];
		[mapView showPassedAndRemainingRouteResultOnCurrentFloor:localPoint];
		return;
	}

	mapView.callout.customView = [self customView:mappoint];
	[mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
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
	if (routePartArray.count > 0) {
		currentRoutePart = [routePartArray objectAtIndex:0];
	}

	//缩放到路段
	if (currentRoutePart) {
		[self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:80 animated:YES];
	}
}

@end
