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
    [self.mapView setGridLineWidth:4];
    [self.mapView setGridLineColor:[UIColor lightGrayColor]];
    
    [self.mapView setGridSize:8];
    [self.mapView setBackgroundColor:[UIColor darkGrayColor]];
    
}

#pragma mark - **************** 地图回调

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    //地图文字颜色
//    [self.mapView setLabelColor:[UIColor blueColor]];
	//限制基于mapView宽设置缩放倍数，最小0.5~最大8倍
//	[self setMinMaxResolution:0.5:8];
}
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    [super TYMapView:mapView didFinishLoadingFloor:mapInfo];
	NSLog(@"%@",mapInfo);
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
	NSLog(@"%@,%@,%@",mappoint,[mapView toMapPoint:CGPointMake(mappoint.x, mappoint.y)],NSStringFromCGPoint([mapView toScreenPoint:mappoint]));
    TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
    if (poi) {
        NSLog(@"poi:%@",poi);
        [mapView highlightPoi:poi];
        if ([poi.geometry isKindOfClass:[AGSPolygon class]]) {
            AGSPoint *point = [[AGSGeometryEngine defaultGeometryEngine] labelPointForPolygon:(AGSPolygon *)poi.geometry];
            [mapView showLocation:[TYLocalPoint pointWithX:point.x Y:point.y Floor:mapView.currentMapInfo.floorNumber]];
        }
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView {
	NSLog(@"分辨率：%f米/像素，当前屏幕宽度=实际%f米",self.mapView.resolution,self.mapView.resolution*[UIScreen mainScreen].bounds.size.width);
}

#pragma mark - **************** 分辨率
//设置以当前地图宽为基准，最大maxScale倍数，和最小倍数minScale
- (void) setMinMaxResolution:(double) minScale :(double) maxScale {
	double width = self.mapView.frame.size.width;
    double distance = self.mapView.currentMapInfo.mapSize.x;
    double resolution = distance/width;

	[self.mapView setMaxResolution:minScale*resolution];
	[self.mapView setMinResolution:resolution/maxScale];
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
