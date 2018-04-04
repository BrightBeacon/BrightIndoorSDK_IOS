//
//  ControlNorthVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "ControlNorthVC.h"
#import "UIImageView+AGSNorthArrow.h"

@interface ControlNorthVC ()

@end

@implementation ControlNorthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *northImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"northarrow"]];
    northImageView.center = CGPointMake(30, 120);
    northImageView.mapViewForNorthArrow = self.mapView;
    [self.view addSubview:northImageView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"旋转" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rotateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)rotateButtonClicked:(id)sender {
    [self.mapView setRotationAngle:arc4random()%360 animated:YES];
}

@end
