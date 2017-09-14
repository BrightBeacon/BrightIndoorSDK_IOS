//
//  beaconVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocationVC.h"
#import <TYLocationEngine/TYLocationEngine.h>
//登录http://open.brtbeacon.com，查看主动定位，点位管理

@interface LocationVC ()<TYLocationManagerDelegate> {
    int picIndex;
}

@property (nonatomic ,strong) TYLocationManager *locationManager;
@property (nonatomic ,strong) CLLocationManager *lm;

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setImage:[UIImage imageNamed:@"locbutton"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(locButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.locationManager stopUpdateLocation];
	self.locationManager = nil;
}

- (IBAction)locButtonClicked:(id)sender {
    if (!self.locationManager) {
        
        //可选设置请求运行时位置权限；需plist对应配置
        [TYBLEEnvironment setRequestWhenInUseAuthorization:YES];
        
        //初始化定位数据
        self.locationManager = [[TYLocationManager alloc] initWithBuilding:kBuildingId appKey:kAppKey];
        
        //设置定位设备信号阀值
        [self.locationManager setRssiThreshold:-90];
        self.locationManager.delegate = self;
       
        //开启定位热力数据上传
        [self.locationManager enableHeatData:YES];
    }
    
    //启动定位
    [self.locationManager startUpdateLocation];
}

- (void)animateLocationSymbol {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateLocationSymbol) object:nil];
    if (picIndex > 7) {
        picIndex = 0;
        [self.mapView setLocationSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"l0"]];
        return;
    }
    NSString *picName = [NSString stringWithFormat:@"l%d",picIndex++];
    [self.mapView setLocationSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:picName]];
    [self performSelector:@selector(animateLocationSymbol) withObject:nil afterDelay:0.15];
}


#pragma mark - **************** 地图回调方法

- (void)TYMapViewDidLoad:(TYMapView *)mapView withError:(NSError *)error{
    [super TYMapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    
    [self.mapView setLocationSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"locationArrow"]];
	//设置地图方向跟随模式(定位图标旋转/整个地图旋转)
	[self.mapView setMapMode:TYMapViewModeFollowing];

}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    NSLog(@"%@",mappoint);
    if (self.locationManager.getLastLocation) {
        [self.mapView.routeManager requestRouteWithStart:self.locationManager.getLastLocation End:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber]];
    }
    
    
    [self.mapView setLocationSymbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"locationArrow"]];
    [self.mapView showLocation:[TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber]];
//    [self animateLocationSymbol];
}


#pragma mark - **************** 定位回调方法

/**
 位置更新回调，位置较稳定，适合步行场景下

 @param manager 定位引擎
 @param newLocation 新的位置结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation {
    if(self.mapView.loaded){
        [self.mapView showLocation:newLocation];
//        [self animateLocationSymbol];
    }
}

/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 与[TYLocationManager:didUpdateLocatin:]方法相近，此方法回调结果实时返回当前位置，灵敏度较高，适合用于行车场景下
 *
 *  @param manager     定位引擎实例
 *  @param newLocation 新的位置结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateImmediateLocation:(TYLocalPoint *)newImmediateLocation {
	//NSLog(@"您的位置：%@",newImmediateLocation);
	//[self.mapView showLocation:newImmediateLocation];
}

/**
 *  位置更新失败事件回调
 *
 *  @param manager 定位引擎实例
 */
- (void)TYLocationManager:(TYLocationManager *)manager didFailUpdateLocation:(NSError *)error {
	NSLog(@"定位失败：%@",error);
}

/**
 *  Beacon扫描结果事件回调，返回符合扫描参数的所有Beacon
 *
 *  @param manager 定位引擎实例
 *  @param beacons Beacon数组，[TYBeacon]
 */
- (void)TYLocationManager:(TYLocationManager *)manager didRangedBeacons:(NSArray *)beacons {
//	NSLog(@"all beacons find:%@",beacons);
}

/**
 *  定位Beacon扫描结果事件回调，返回符合扫描参数的定位Beacon，定位Beacon包含坐标信息。此方法可用于辅助巡检，以及基于定位beacon的相关触发事件。
 *
 *  @param manager 定位引擎实例
 *  @param beacons 定位Beacon数组，[TYPublicBeacon]
 */
- (void)TYLocationManager:(TYLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons {
	NSLog(@"location beacons find:%d",(int)beacons.count);
    AGSGraphicsLayer *layer = (AGSGraphicsLayer *)[self.mapView mapLayerForName:@"test"];
    if (layer == nil) {
        layer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:layer withName:@"test"];
    }
    [layer removeAllGraphics];
    NSMutableArray *marray = [NSMutableArray array];
    int i = 0;
    for (TYPublicBeacon *b in beacons) {
        i++;
        if (b.location.floor == self.mapView.currentMapInfo.floorNumber) {
            AGSGraphic *g = [AGSGraphic graphicWithGeometry:[AGSPoint pointWithX:b.location.x y:b.location.y spatialReference:self.mapView.spatialReference] symbol:[AGSTextSymbol textSymbolWithText:[NSString stringWithFormat:@"%@,%d(%d)",b.minor,b.rssi,i] color:[UIColor redColor]] attributes:nil];
            [marray addObject:g];
        }
    }
    [layer addGraphics:marray];
}

/**
 *  设备方向改变事件回调。结合地图setMapMode可以处理地图自动旋转，以及方向箭头等功能。
 *
 *  @param manager    定位引擎实例
 *  @param newHeading 新的设备方向结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateDeviceHeading:(double)newHeading {
	NSLog(@"地图初始北偏角：%f，当前设备北偏角：%f",self.mapView.building.initAngle,newHeading);
	//初始北偏角内部已经处理
	[self.mapView processDeviceRotation:newHeading];
}
@end
