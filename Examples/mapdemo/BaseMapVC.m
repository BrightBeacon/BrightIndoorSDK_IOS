//
//  BaseMapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "BaseMapVC.h"
#import <TYMapData/BRTStatisticManager.h>

@interface BaseMapVC ()<UIActionSheetDelegate>{
    UIButton *_floorButton;
}

@property (nonatomic,strong) TYBuilding *currentBuilding;

@end

@implementation BaseMapVC

- (void)viewDidLoad {
	[super viewDidLoad];

    [TYMapEnvironment initMapEnvironment];
//    [TYMapEnvironment setMapLanguage:TYEnglish];
    self.mapView = [[TYMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    self.mapView.mapDelegate = self;
    [self.mapView initMapViewWithBuilding:kBuildingId AppKey:kAppKey];
    [self showZoomControl];
}

- (void)dealloc {
	NSLog(@"check if '%@' recycled",NSStringFromClass(self.class));
}

#pragma mark - **************** 常用控件

- (void)showFloorControl
{
    [_floorButton removeFromSuperview];
    
    _floorButton = [[UIButton alloc] initWithFrame:CGRectMake(100, self.view.frame.size.height-60, self.view.bounds.size.width-200, 42)];
    _floorButton.layer.cornerRadius = 21;
    [_floorButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _floorButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _floorButton.layer.borderWidth = 1.0;
    [_floorButton setBackgroundColor:[UIColor whiteColor]];
    [_floorButton setTitle:[self.mapView.allMapInfo.firstObject valueForKey:@"floorName"] forState:UIControlStateNormal];
    [_floorButton addTarget:self action:@selector(showFloor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_floorButton];
}

- (void)showFloor:(UIButton *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (TYMapInfo *mapInfo in self.mapView.allMapInfo) {
        [sheet addButtonWithTitle:mapInfo.floorName];
    }
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != actionSheet.cancelButtonIndex){
        [self.mapView setFloor:[actionSheet buttonTitleAtIndex:buttonIndex]];
        [_floorButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
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

#pragma mark - **************** 地图回调
//加载地图回调
- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
	NSLog(@"%@",NSStringFromSelector(_cmd));
    if (!error) {
        [self showFloorControl];
        [self.mapView setFloorWithInfo:mapView.allMapInfo.firstObject];
        self.mapView.backgroundColor = [UIColor whiteColor];
        self.mapView.highlightPOIOnSelection = NO;
        self.mapView.allowRotationByPinching = YES;
    }else{
        [[[UIAlertView alloc] initWithTitle:error.domain message:[NSString stringWithFormat:@"参考错误码%ld",error.code] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

//地图楼层切换
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
}

//Poi选中
- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    for (TYPoi *poi in array) {
        NSLog(@"POI:%@->分类：%d",poi.poiID,poi.categoryID);
    }
}

//地图点击
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    NSLog(@"%@",mappoint);
	TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
	if (poi) {
		[mapView highlightPoi:poi];
    }else{
        NSLog(@"请选择地图内的点");
    }
}

- (BOOL)TYMapView:(TYMapView *)mapView shouldProcessClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    return YES;
}
#pragma mark - **************** 路径规划

//路径规划失败
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
}
//路径规划成功
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
}

#pragma mark - **************** 默认弹窗
- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
	return YES;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout{

}
@end
