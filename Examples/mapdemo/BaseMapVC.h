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
#define kBuildingId @"ZS030002"
#define kAppKey @"ZSYSJZ83ce7c4cf094cd17d170b3d880"
//**********************************以上必须修改***********************************

@interface BaseMapVC : UIViewController<TYMapViewDelegate,TYOfflineRouteManagerDelegate>

@property (nonatomic,strong) TYMapView *mapView;


- (void)showFloorControl;
- (void)showZoomControl;

@end
