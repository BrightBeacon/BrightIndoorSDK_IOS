//
//  CalloutVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/14.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "CalloutVC.h"

@interface CalloutVC ()<AGSCalloutDelegate>

@end

@implementation CalloutVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showZoomControl];
	[self showFloorControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//自定义View
- (UIView *)customView:(TYPoi *)poi {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
	titleLabel.text = @"自定义弹窗";
	[view addSubview:titleLabel];


	UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 200, 25)];
	detailLabel.text = poi.name;
	[view addSubview:detailLabel];

	UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 58, 80, 44)];
	[leftbtn setBackgroundColor:[UIColor redColor]];
	[leftbtn setTitle:@"取消" forState:UIControlStateNormal];
	[leftbtn addTarget:self.mapView.callout action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:leftbtn];

	UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(200-8-80, 58, 80, 44)];
	[rightbtn setBackgroundColor:[UIColor greenColor]];
	[rightbtn setTitle:@"确定" forState:UIControlStateNormal];
	[rightbtn setTitle:poi.poiID forState:UIControlStateApplication];
	[rightbtn addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:rightbtn];
	return view;
}


- (IBAction)doneButtonClicked:(UIButton *)sender {
	//通过poiID索引POI
	TYPoi *poi = [self.mapView getPoiOnCurrentFloorWithPoiID:[sender titleForState:UIControlStateApplication] layer:POI_ROOM];
	[[[UIAlertView alloc] initWithTitle:poi.name message:poi.poiID delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	[self.mapView.callout dismiss];
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
	//通过X、Y搜索点击的POI
	TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
	if (![poi.name isEqual:[NSNull null]]) {
		mapView.callout.customView = [self customView:poi];
	}else{
		mapView.callout.title = @"默认弹窗";
		mapView.callout.detail = [NSString stringWithFormat:@"%f,%f",mappoint.x,mappoint.y];
		mapView.callout.delegate = self;
	}
	[mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}

#pragma mark - **************** 默认弹窗事件

-(void)calloutWillDismiss:(AGSCallout*)callout {
	NSLog(@"%@",NSStringFromSelector(_cmd));
}

-(void)calloutDidDismiss:(AGSCallout*)callout {
	NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
	TYPoi *poi = [self.mapView extractRoomPoiOnCurrentFloorWithX:callout.mapLocation.x Y:callout.mapLocation.y];
	NSLog(@"didClickAccessoryButtonForCallout:%@",poi.poiID);
}
@end
