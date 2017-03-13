//
//  BaseMapVC.h
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYMapSDK/TYMapSDK.h>
//防止数据中出现NSNull崩溃
#import "NSNull+OVNatural.h"

//**********************************以下必须修改***********************************
//以下地图初始化、检查更新参数参看：http://developer.brtbeacon.com/map/myMapList
#define kBuildingId @"ZS020006"
#define kAppKey @"efef3dbde9dd416bb24b213ed546584f"
#define kLicense @"608d7b30DwYwMDM2MT8brtd_ZmY2YWYyNjQbrtd_c1de8012"
//**********************************以上必须修改***********************************

@interface BaseMapVC : UIViewController<TYMapViewDelegate,TYOfflineRouteManagerDelegate>

@property (nonatomic,strong) IBOutlet TYMapView *mapView;
@property (nonatomic,readonly) NSArray *allMapInfo;
@property (nonatomic,strong) TYOfflineRouteManager *routeManager;

- (void)showFloorControl;
- (void)showZoomControl;

@end
