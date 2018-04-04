//
//  LineVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "LineVC.h"

@interface LineVC ()
{
    AGSGraphicsLayer *hintLayer;
    AGSMutablePolyline *polyline;
    UILabel *tipLabel;
}
@end

@implementation LineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    [polyline addPathToPolyline];
    
    tipLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    [self.view addSubview:tipLabel];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    [polyline addPointToPath:mappoint];
    
    if (hintLayer == nil) {
        hintLayer = [AGSGraphicsLayer graphicsLayer];
        [mapView addMapLayer:hintLayer];
    }
    AGSGraphic *graphic = [AGSGraphic graphicWithGeometry:polyline symbol:[AGSSimpleLineSymbol simpleLineSymbol] attributes:nil];
    [hintLayer addGraphic:graphic];
    
    tipLabel.text = [NSString stringWithFormat:@"全长%.2f米",[[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:polyline]];
}

@end
