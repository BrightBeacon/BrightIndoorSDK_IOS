//
//  BaseMapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "BaseMapVC.h"

@interface BaseMapVC (){
    UISegmentedControl *_floorSegment;
}

@property (nonatomic,strong) TYBuilding *currentBuilding;

@end

@implementation BaseMapVC

- (void)viewDidLoad {
	[super viewDidLoad];

    [TYMapEnvironment initMapEnvironment];
    [TYMapEnvironment setRootDirectoryForMapFiles:[[NSBundle mainBundle] pathForResource:@"Map" ofType:nil]];
    [self.mapView initMapViewWithBuilding:kBuildingId AppKey:kAppKey];
    self.mapView.mapDelegate = self;
    [self.mapView setFloor:@"F1"];

    [self showZoomControl];
}

- (void)dealloc {
	NSLog(@"check if '%@' recycled",NSStringFromClass(self.class));
}

- (void)initMap {

    self.mapView.backgroundColor = [UIColor whiteColor];

    self.mapView.highlightPOIOnSelection = NO;
    self.mapView.allowRotationByPinching = YES;

}

#pragma mark - **************** 常用控件

- (void)showFloorControl
{
    [_floorSegment removeFromSuperview];
	if (self.mapView.allMapInfo.count<=1) {
		return;
	}
	NSMutableArray *floorNameArray = [[NSMutableArray alloc] init];
	for (TYMapInfo *mapInfo in self.mapView.allMapInfo) {
		[floorNameArray addObject:mapInfo.floorName];
	}
    _floorSegment = [[UISegmentedControl alloc] initWithItems:floorNameArray];
	_floorSegment.frame = CGRectMake(20, 80, self.view.frame.size.width - 20 * 2, 30);
	_floorSegment.tintColor = [UIColor blueColor];
	_floorSegment.selectedSegmentIndex = 0;
	[_floorSegment addTarget:self action:@selector(floorChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_floorSegment];
}
//地图按2倍率缩放
- (void)showZoomControl {
	CGRect frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 160, 40, 40);
	UIButton *zin = [[UIButton alloc] initWithFrame:frame];
	[zin setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
	[zin addTarget:self.mapView action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zin];

	frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 120, 40, 40);
	UIButton *zout = [[UIButton alloc] initWithFrame:frame];
	[zout setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
	[zout addTarget:self.mapView action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zout];
}

//切换楼层
- (IBAction)floorChanged:(UISegmentedControl *)sender {
	[self.mapView setFloorWithInfo:[self.mapView.allMapInfo objectAtIndex:sender.selectedSegmentIndex]];
}

#pragma mark - **************** 地图回调
//加载地图回调
- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
	NSLog(@"%@",NSStringFromSelector(_cmd));
    if (!error) {
        [self showFloorControl];
    }
}

//地图楼层切换
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
	NSLog(@"%@",NSStringFromSelector(_cmd));
}

//Poi选中
- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
//	TYPoi *poi = array.firstObject;
//	if (![poi isEqual:[NSNull null]]) {
//		[mapView highlightPoi:poi];
//	}
}

//地图点击
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
//	TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
//	if (![poi isEqual:[NSNull null]]) {
//		[mapView highlightPoi:poi];
//	}
}

#pragma mark - **************** 路径规划

//路径规划失败
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
}
//路径规划成功
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
}

#pragma mark - **************** 默认弹窗
- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
	return YES;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout{

}
@end
