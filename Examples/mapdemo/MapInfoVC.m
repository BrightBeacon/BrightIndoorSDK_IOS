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
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 140)];
    self.tipsLabel.numberOfLines = 0;
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, 44, 44)];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    //在文件目录中确认多语言类型对应的路径
    //重叠碰撞检测
    //[self.mapView setLabelOverlapDetectingEnabled:NO];
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error {
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        self.tipsLabel.text = error.description;
    }else {
        //设置缩放显示Label层级0~5和对应地图分辨率 scale:mapScale，需配合Label数据中最大最小显示等级设置。
        [self.mapView setScaleLevels:@{@(0):@(2500),@(1):@(2000),@(2):@(1500),@(3):@(1000),@(4):@(500),@(5):@(100)}];
    }
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    NSString *tips = [NSString stringWithFormat:@"地图信息：%@  \n北偏角：%0.2f\n楼层信息：%@\n比例尺：%.2f米/1厘米\n分辨率：%.2f米/1像素",mapView.building.name,mapView.building.initAngle,mapInfo.mapID,mapView.mapScale/100.0,mapView.resolution];
    self.tipsLabel.text = tips;
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView {
    CGFloat virtualPointOfMapView = self.mapView.frame.size.width;
    NSString *tips = [NSString stringWithFormat:@"%@  \n北偏角：%0.2f\n旋转角：%0.2f\n比例尺：%.2f米/1厘米\n分辨率：%.2f米/1像素点\n当前View宽%.0f像素点=实际%.2f米",
                      self.mapView.building.name,
                      self.mapView.building.initAngle,
                      self.mapView.rotationAngle,
                      self.mapView.mapScale/100.0,self.mapView.resolution,
                      virtualPointOfMapView,
                      self.mapView.resolution*virtualPointOfMapView];
    self.tipsLabel.text = tips;
}

- (IBAction)resetButtonClicked:(id)sender {
    [self.mapView setRotationAngle:0];
    [self.mapView zoomToResolution:self.mapView.currentMapInfo.mapSize.x/self.mapView.frame.size.width animated:YES];
    [self.mapView centerAtPoint:self.mapView.baseLayer.fullEnvelope.center animated:NO];
}
@end
