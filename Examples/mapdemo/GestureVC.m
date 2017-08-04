//
//  GestureVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "GestureVC.h"

@interface GestureVC ()<AGSMapViewTouchDelegate>{
    UIButton *moveButton;
}
@end

@implementation GestureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 200, 100, 44)];
    [btn setTitle:@"禁止双指" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"禁止缩放" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"禁止点击" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    moveButton = btn;
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 3;
    [btn setTitle:@"禁止移动" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self.mapView setAllowRotationByPinching:sender.isSelected];
            break;
        case 1:
        {
            double resolution = self.mapView.currentMapInfo.mapSize.x/self.mapView.frame.size.width;
            if (sender.isSelected) {
                [self.mapView setMinResolution:resolution*0.5];
                [self.mapView setMaxResolution:resolution*5];
            }else {
                [self.mapView setMinResolution:resolution];
                [self.mapView setMaxResolution:resolution];
            }
        }
            break;
        case 3:
        {
            self.mapView.userInteractionEnabled = sender.isSelected;
        }
            break;
            
        default:
            break;
    }
    [sender setSelected:!sender.isSelected];
}

- (BOOL)TYMapView:(TYMapView *)mapView shouldProcessClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    return moveButton.isSelected;
}

@end
