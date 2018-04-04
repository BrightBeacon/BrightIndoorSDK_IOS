//
//  MapLayer.m
//  mapdemo
//
//  Created by thomasho on 2017/7/28.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapLayer.h"

@interface MapLayer ()

@end

@implementation MapLayer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    [btn setTitle:@"文字优先" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"隐藏文字层" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"隐藏设施层" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self.mapView setLabelPriority:!sender.isSelected];
            [self.mapView reloadMapView];
            break;
        case 1:
            [self.mapView mapLayerForName:@"LabelLayer"].visible = sender.isSelected;
            break;
        case 2:
            [self.mapView mapLayerForName:@"FacilityLayer"].visible = sender.isSelected;
            break;
            
        default:
            break;
    }
    [sender setSelected:!sender.isSelected];
}

@end
