//
//  FenceVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "FenceVC.h"
#import <math.h>

@interface FenceVC () {
    AGSSymbol   *symbol;
    AGSGraphic  *fenceGraphic;
    AGSGraphic  *markerGraphic;
}

@end

@implementation FenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"移动标点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    symbol = [[AGSSimpleMarkerSymbol alloc] initWithColor:[UIColor redColor]];
}

- (IBAction)moveButtonClicked:(id)sender {
    //以x+1，y-1：右下方移动，当前标记点marker
    AGSPoint *oldMarkerCenter = (AGSPoint *)markerGraphic.geometry;
    markerGraphic.geometry = [AGSPoint pointWithX:oldMarkerCenter.x + 1 y:oldMarkerCenter.y - 1 spatialReference:oldMarkerCenter.spatialReference];
    [self checkContainStatus];
}

//检查标记，中心点是否在围栏范围内
- (void)checkContainStatus {
    BOOL isIn = [[AGSGeometryEngine defaultGeometryEngine] geometry:fenceGraphic.geometry containsGeometry:markerGraphic.geometry];
    if (isIn) {
        self.title = @"围栏内";
    }else{
        self.title = @"围栏外";
    }
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    
    AGSGraphicsLayer *glayer = [AGSGraphicsLayer graphicsLayer];
    [mapView addMapLayer:glayer withName:@"glayer"];
    
    //根据半径r=地图1/4宽，添加圆形围栏，并填充颜色
    TYMapInfo *mapInfo = mapView.allMapInfo.firstObject;
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:mapInfo.mapExtent.xmin ymin:mapInfo.mapExtent.ymin xmax:mapInfo.mapExtent.xmax ymax:mapInfo.mapExtent.ymax spatialReference:TYMapEnvironment.defaultSpatialReference];
    fenceGraphic = [AGSGraphic graphicWithGeometry:[self getCircle:env.center R:(env.xmax-env.xmin)/4] symbol:[AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithWhite:0 alpha:0.2] outlineColor:[UIColor redColor]] attributes:nil];
    [glayer addGraphic:fenceGraphic];
    
    //添加移动标记
    AGSPoint *pt = [AGSPoint pointWithX:env.xmin y:env.ymax spatialReference:TYMapEnvironment.defaultSpatialReference];
    markerGraphic = [AGSGraphic graphicWithGeometry:pt symbol:symbol attributes:nil];
    [glayer addGraphic:markerGraphic];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    //点击绘制自定义围栏,默认半径r = 5
    AGSGraphicsLayer *glayer = (AGSGraphicsLayer *)[mapView mapLayerForName:@"glayer"];
    [glayer removeGraphic:fenceGraphic];
    
    fenceGraphic = [AGSGraphic graphicWithGeometry:[self getCircle:mappoint R:5] symbol:[AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithWhite:0 alpha:0.2] outlineColor:[UIColor redColor]] attributes:nil];
    [glayer addGraphic:fenceGraphic];
    
    
    [self checkContainStatus];
}

//	画圆形
- (AGSPolygon *)getCircle:(AGSPoint *)center R:(double) radius {
    NSArray *points = [self getPoints:center R:radius];
    AGSMutablePolygon *circle = [[AGSMutablePolygon alloc] initWithSpatialReference:TYMapEnvironment.defaultSpatialReference];
    [circle addRingToPolygon];
    for (int i = 0; i < points.count; i++)
        [circle addPointToRing:points[i]];
    return circle;
}

- (NSArray *)getPoints:(AGSPoint *)center R:(double) radius {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:50];
    double sin;
    double cos;
    double x;
    double y;
    for (double i = 0; i < 50; i++) {
        sin = sinf(M_PI * 2 * i / 50.0);
        cos = cosf(M_PI * 2 * i / 50.0);
        x = center.x + radius * sin;
        y = center.y + radius * cos;
        points[(int) i] = [AGSPoint pointWithX:x y:y spatialReference:TYMapEnvironment.defaultSpatialReference];
    }
    return points;
}
@end
