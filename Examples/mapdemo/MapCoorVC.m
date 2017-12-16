//
//  MapCoorVC.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapCoorVC.h"
#import "TYMapConvert.h"

@interface MapCoorVC ()

@property (nonatomic,strong) UILabel *tipsLabel;

@property (nonatomic,strong) NSArray *mapBaseCoors;
@property (nonatomic,strong) NSArray *customCoors;

@end

@implementation MapCoorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 80)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = @"坐标转换";
    [self.view addSubview:self.tipsLabel];
    
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (!error) {
        double xmin = mapView.currentMapInfo.mapExtent.xmin;
        double xmax = mapView.currentMapInfo.mapExtent.xmax;
        double ymin = mapView.currentMapInfo.mapExtent.ymin;
        double ymax = mapView.currentMapInfo.mapExtent.ymax;
        self.mapBaseCoors = @[@(xmin),@(ymin),@(xmax),@(ymin),@(xmin),@(ymax)];
        self.customCoors = @[@(0),@(100),@(100),@(100),@(0),@(0)];
        
        AGSGraphicsLayer *layer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:layer];
        AGSGraphic *g = [AGSGraphic graphicWithGeometry:[AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:mapView.spatialReference] symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor]] attributes:nil];
        [layer addGraphic:g];
    }
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    CGPoint pt = [TYMapConvert convert:self.mapBaseCoors to:self.customCoors x:mappoint.x y:mappoint.y];
    self.tipsLabel.text = [NSString stringWithFormat:@"屏幕坐标：%.4f,%.4f\n地图坐标：%.4f,%.4f\n自定义00坐标：%.4f,%.4f",screen.x,screen.y,mappoint.x,mappoint.y,pt.x,pt.y];
    
    [mapView toScreenPoint:mappoint];
    [mapView toMapPoint:screen];
    
    [mapView clearRouteLayer];
    [mapView showRouteEndSymbolOnCurrentFloor:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber]];
}

@end
