//
//  MapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - **************** 地图回调

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:error.domain message:[NSString stringWithFormat:@"参考错误码%ld",error.code] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
	//限制屏幕宽显示范围5米-100米
	[self setMinMaxResolution:5 :100];
}
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
	NSLog(@"%@",mapInfo);
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
	NSLog(@"%@",mappoint);
	TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
	if (poi) {
		[mapView highlightPoi:poi];
	}
    if ([mapView.building.buildingID isEqualToString:kBuildingId]) {
        [mapView switchBuilding:@"ZS010005" AppKey:@"efef3dbde9dd416bb24b213ed546584f"];
        [mapView setFloor:@"F1"];
    }else{
        [mapView switchBuilding:kBuildingId AppKey:kAppKey];
        [mapView setFloor:@"F1"];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView {
	NSLog(@"分辨率：%f米/像素，当前屏幕宽度=实际%f米",self.mapView.resolution,self.mapView.resolution*[UIScreen mainScreen].bounds.size.width);
}

#pragma mark - **************** 分辨率
//设置当前屏幕宽能显示的最小、最大实际距离(米)
- (void) setMinMaxResolution:(double) min :(double) max {
	//resolution 实际距离（米）/屏幕像素
	double width = [UIScreen mainScreen].bounds.size.width;
	[self.mapView setMaxResolution:max/width];//分辨率：max米/屏幕宽像素
	[self.mapView setMinResolution:min/width];//分辨率：min米/屏幕宽像素
}

- (IBAction)resolutionButtonClicked:(UISlider *)sender {
	//缩放分辨率：?米/宽度
	double width = self.mapView.frame.size.width;
	double distance = (self.mapView.maxResolution*width)*sender.value;
	[self.mapView zoomToResolution:distance/width animated:NO];
}

- (IBAction)enveloperButtonClicked:(id)sender {
	//设置显示区域
    //AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:<#(double)#> ymin:<#(double)#> xmax:<#(double)#> ymax:<#(double)#> spatialReference:<#(AGSSpatialReference *)#>]
	[self.mapView zoomToEnvelope:self.mapView.baseLayer.fullEnvelope animated:YES];
}
@end
