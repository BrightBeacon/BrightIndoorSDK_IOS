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
//以下地图初始化参数参看：http://open.brtbeacon.com
//#define kBuildingId @"ZS020006"
//#define kAppKey @"efef3dbde9dd416bb24b213ed546584f"
#define kBuildingId @"00270002"
#define kAppKey @"2d56314c042c4b0ba694f65a0c70ae10"

//**********************************以上必须修改***********************************

@interface BaseMapVC : UIViewController<TYMapViewDelegate,TYOfflineRouteManagerDelegate>

@property (nonatomic,strong) IBOutlet TYMapView *mapView;


- (void)showFloorControl;
- (void)showZoomControl;

@end
