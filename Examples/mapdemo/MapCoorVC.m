//
//  MapCoorVC.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapCoorVC.h"

@interface MapCoorVC ()

@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation MapCoorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 80)];
    self.tipsLabel.numberOfLines = 2;
    self.tipsLabel.text = @"坐标转换";
    [self.view addSubview:self.tipsLabel];
    
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    
    self.tipsLabel.text = [NSString stringWithFormat:@"屏幕坐标：%.4f,%.4f\n地图坐标：%.4f,%.4f",screen.x,screen.y,mappoint.x,mappoint.y];
    
    [mapView toScreenPoint:mappoint];
    [mapView toMapPoint:screen];
    
    [mapView clearRouteLayer];
    [mapView showRouteEndSymbolOnCurrentFloor:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber]];
}

@end
