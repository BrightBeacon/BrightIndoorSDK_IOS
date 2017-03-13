//
//  beaconVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocationVC.h"
#import "LocDataSync.h"
#import <TYLocationEngine/TYLocationEngine.h>
#import "UIImageView+AGSNorthArrow.h"

//登录http://developer.brtbeacon.com，查看主动定位，点位管理，获取当前建筑UUID
#define kUUID @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"

@interface LocationVC ()<TYLocationManagerDelegate>{
    TYLocalPoint *lastLocation,*currentLocation;
}

@property (nonatomic ,strong) TYLocationManager *locationManager;

@property (nonatomic ,assign) IBOutlet UIImageView *northImageView;

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];

	[self showZoomControl];
	[self showFloorControl];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.locationManager stopUpdateLocation];
	self.locationManager = nil;
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.locationManager) {
		[self.locationManager startUpdateLocation];
	}
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView {

	//设置地图显示定位图标
	AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
	[self.mapView setLocationSymbol:locSymbol];

	//设置方向跟随模式(定位图标旋转/整个地图旋转)
	[self.mapView setMapMode:TYMapViewModeFollowing];

	//设置指北针
	self.northImageView.mapViewForNorthArrow  = self.mapView;

	//设置定位数据路径
	[self setBLEEnvironment:kBuildingId];

	//检查定位数据更新
	[LocDataSync updateLocData:[NSString stringWithFormat:url_beaconnew,kBuildingId,kAppKey,kLicense] onCompletion:^(NSError *err) {
		if (err) NSLog(@"无更新定位数据%@",err);
		[self startLocation];
	}];

}

//设置下载定位文件目录
- (void)setBLEEnvironment:(NSString *)buidingId{
	NSString *mapFilePath = [TYMapEnvironment getRootDirectoryForMapFiles];
	//设置定位数据路径，这里直接使用了map的路径
	[TYBLEEnvironment setRootDirectoryForFiles:mapFilePath];
}



- (void)startLocation {
	//初始化定位
	if (!self.locationManager) {
		self.locationManager = [[TYLocationManager alloc] initWithBuilding:self.mapView.building];
		[_locationManager setRssiThreshold:-90];
		[_locationManager setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kUUID] identifier:@"regionIdentifier"]];
		_locationManager.delegate = self;
	}
	[_locationManager startUpdateLocation];
}

#pragma mark - **************** 定位回调
/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 *  与[TYLocationManager:didUpdateImmediationLocation:]方法相近，此方法回调结果融合计步器信息，稳定性较好，适合用于步行场景下。
 *
 *  @param manager     定位引擎实例
 *  @param newLocation 新的位置结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation {
	NSLog(@"您的位置：%@",newLocation);

    //平滑显示定位点
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(currentLocation)lastLocation = currentLocation;
    [self showSmoothLocation:newLocation];
}

- (void)showSmoothLocation:(TYLocalPoint *)newLocation{
    static int idx = 0;
    if (lastLocation.floor == newLocation.floor&&idx<=6) {
        idx++;
        double scale = idx/6.0;
        double x = (1-scale)*lastLocation.x + scale*newLocation.x;
        double y = (1-scale)*lastLocation.y + scale*newLocation.y;
        currentLocation = [TYLocalPoint pointWithX:x Y:y Floor:newLocation.floor];
        [self.mapView showLocation:currentLocation];
        [self performSelector:@selector(showSmoothLocation:) withObject:newLocation afterDelay:1.0/6];
    }else{
        idx = 0;
        [self.mapView showLocation:newLocation];
        lastLocation = newLocation;
    }
}


/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 与[TYLocationManager:didUpdateLocatin:]方法相近，此方法回调结果未融合计步器信息，灵敏度较高，适合用于行车场景下
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
- (void)TYLocationManagerdidFailUpdateLocation:(TYLocationManager *)manager {
	NSLog(@"定位失败");
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
}

/**
 *  设备方向改变事件回调。结合地图Api可以处理地图自动旋转，以及方向箭头等功能。
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
