//
//  BaseMapVC.h
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYMapSDK/TYMapSDK.h>
//**********************************以下必须修改***********************************
//以下地图初始化参数参看：http://open.brtbeacon.com
 #define kBuildingId @"00230021"
 #define kAppKey @"2db1ef00cba1434297fc93a99ae54e37"
//**********************************以上必须修改***********************************

@interface BaseMapVC : UIViewController<TYMapViewDelegate,TYOfflineRouteManagerDelegate>

@property (nonatomic,strong) TYMapView *mapView;


- (void)showFloorControl;
- (void)showZoomControl;

@end
