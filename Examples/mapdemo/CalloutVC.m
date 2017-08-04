//
//  CalloutVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/14.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "CalloutVC.h"

@interface CalloutVC ()<AGSCalloutDelegate>

@property (nonatomic,strong) AGSGraphicsLayer *graphicLayer;

@end

@implementation CalloutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //启用默认弹窗委托
    self.mapView.callout.delegate = self;
}

- (AGSGraphicsLayer *)graphicLayer {
    if (!_graphicLayer) {
        _graphicLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:_graphicLayer withName:@"Graphics Layer"];
        
        //直接设置Layer默认的点渲染方式
        AGSSimpleRenderer* simpleRenderer = [AGSSimpleRenderer simpleRendererWithSymbol:[self getPointSymbol]];
        _graphicLayer.renderer = simpleRenderer;
    }
    return _graphicLayer;
}

-(AGSSimpleMarkerSymbol*)getPointSymbol{
    AGSSimpleMarkerSymbol* pointSymbol = [[AGSSimpleMarkerSymbol alloc]init];
    pointSymbol.color = [UIColor orangeColor];
    pointSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
    pointSymbol.size = CGSizeMake(10, 10);
    return pointSymbol;
}

//自定义弹窗View
- (UIView *)customView:(TYPoi *)poi {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 160, 25)];
	titleLabel.text = @"自定义弹窗";
	[view addSubview:titleLabel];


	UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 160, 25)];
	detailLabel.text = poi.name;
	[view addSubview:detailLabel];

	UIButton *leftbtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 58, 80, 30)];
	[leftbtn setBackgroundColor:[UIColor redColor]];
	[leftbtn setTitle:@"取消" forState:UIControlStateNormal];
    leftbtn.layer.cornerRadius = 15;
	[leftbtn addTarget:self.mapView.callout action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:leftbtn];

	UIButton *rightbtn = [[UIButton alloc] initWithFrame:CGRectMake(200-8-80, 58, 80, 30)];
	[rightbtn setBackgroundColor:[UIColor greenColor]];
	[rightbtn setTitle:@"确定" forState:UIControlStateNormal];
	[rightbtn setTitle:poi.poiID forState:UIControlStateApplication];
    rightbtn.layer.cornerRadius = 15;
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
    //使用自定义弹窗view，或者使用原始view
    if ([poi isEqual:[NSNull null]]||[poi.name isEqual:[NSNull null]]) {
        mapView.callout.customView = nil;
    }else{
        mapView.callout.customView = [self customView:poi];
    }
    [mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
}

#pragma mark - **************** 默认弹窗事件

//需要预先设置弹窗委托self.mapView.callout.delegate = self;
//弹窗即将出现回调；return NO;或self.mapView.allowCallout = NO;均可以控制取消本弹窗。
-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint *)mapPoint {
    if (callout.customView) {
        return NO;
    }
    callout.title = @"默认弹窗";
    callout.image = [UIImage imageNamed:@"redPin"];
    callout.accessoryButtonImage = [UIImage imageNamed:@"locationArrow"];
    return YES;
}
//点击空白区域消失，或手动消失[self.mapView.callout dissmiss];
-(void)calloutWillDismiss:(AGSCallout*)callout {
    
}
-(void)calloutDidDismiss:(AGSCallout*)callout {
    
}
//右侧按钮点击
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    NSLog(@"at layer:%@, with feature:%@",callout.representedLayer,callout.representedObject);
    [self.graphicLayer removeAllGraphics];
    [self.graphicLayer addGraphic:[AGSGraphic graphicWithGeometry:callout.mapLocation symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]] attributes:nil]];
    [callout dismiss];
}
@end
