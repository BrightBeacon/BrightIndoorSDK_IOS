//
//  SearchDistanceVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchDistanceVC.h"

@interface SearchDistanceVC ()

@end

@implementation SearchDistanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    
    AGSGraphicsLayer *layer = (AGSGraphicsLayer *)[mapView mapLayerForName:@"poilayer"];
    if (layer == nil) {
        layer = [AGSGraphicsLayer graphicsLayer];
        layer.renderer = [AGSSimpleRenderer simpleRendererWithSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"greenPin"]];
        layer.selectionSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"redPin"];
        [mapView addMapLayer:layer withName:@"poilayer"];
    }
    [layer removeAllGraphics];
    AGSPolygon *circle = [self getCircle:mappoint R:5];
    [layer addGraphic:[AGSGraphic graphicWithGeometry:circle symbol:[AGSSimpleFillSymbol simpleFillSymbolWithColor:[UIColor colorWithWhite:0 alpha:0.75] outlineColor:[UIColor redColor]] attributes:nil]];
    
    TYSearchAdapter *searchAdapter  = [[TYSearchAdapter alloc] initWithBuildingID:kBuildingId distinct:1];
    NSArray *pois = [searchAdapter queryPoiByCenter:mappoint Radius:5 Floor:mapView.currentMapInfo.floorNumber];
    NSMutableArray *graphics = [NSMutableArray array];
    for (PoiEntity *pe in pois) {
        AGSPoint *point = [AGSPoint pointWithX:pe.labelX.floatValue y:pe.labelY.floatValue spatialReference:self.mapView.spatialReference];
        AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:@{@"NAME":pe.name}];
        [graphics addObject:graphic];
    }
    [layer addGraphics:graphics];
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
