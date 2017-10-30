//
//  MapSetting.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapSetting.h"

@interface MapSetting ()

@end

@implementation MapSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    [btn setTitle:@"缩放地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"旋转地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"移到中心点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            //Resolution = 实际距离米/显示的分辨率
            //设置缩放限制，[6米-1000米]
            [self.mapView setMaxResolution:1000/self.mapView.frame.size.width];
            [self.mapView setMinResolution:6/self.mapView.frame.size.width];
            
            //betterResolution即：建筑最大实际距离/mapView宽度 （mapView刚好显示整个地图），可以据此值进行2的指数倍缩放。
            double betterResolution = self.mapView.currentMapInfo.mapSize.x/self.mapView.frame.size.width;
            [self.mapView zoomToResolution:betterResolution/2.0 animated:YES];
            break;
        case 1:
            [self.mapView setRotationAngle:180 aroundScreenPoint:self.view.center animated:YES];
            break;
        case 2:
            [self.mapView centerAtPoint:self.mapView.baseLayer.fullEnvelope.center animated:YES];
            break;
            
        default:
            break;
    }
}

@end
