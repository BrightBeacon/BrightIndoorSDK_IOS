//
//  MapInfoVC.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/18.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapInfoVC.h"

@interface MapInfoVC ()

@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation MapInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 100)];
    self.tipsLabel.numberOfLines = 0;
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, 44, 44)];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (error != nil) {
        self.tipsLabel.text = error.description;
    }
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    NSString *tips = [NSString stringWithFormat:@"地图信息：%@  \n北偏角：%0.2f\n楼层信息：%@\n比例尺：%f",mapView.building.name,mapView.building.initAngle,mapInfo.mapID,mapView.mapScale];
    self.tipsLabel.text = tips;
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView {
    NSString *tips = [NSString stringWithFormat:@"地图信息：%@  \n北偏角：%0.2f\n旋转角：%0.2f\n比例尺：%f",self.mapView.building.name,self.mapView.building.initAngle,self.mapView.rotationAngle,self.mapView.mapScale];
    self.tipsLabel.text = tips;
}

- (IBAction)resetButtonClicked:(id)sender {
    [self.mapView setRotationAngle:0];
    [self.mapView zoomToResolution:self.mapView.currentMapInfo.mapSize.x/self.mapView.frame.size.width animated:YES];
    [self.mapView centerAtPoint:self.mapView.baseLayer.fullEnvelope.center animated:NO];
}
@end
