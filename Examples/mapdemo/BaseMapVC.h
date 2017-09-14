//
//  BaseMapVC.h
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYMapSDK/TYMapSDK.h>

@interface BaseMapVC : UIViewController<TYMapViewDelegate,TYOfflineRouteManagerDelegate>

@property (nonatomic,strong) TYMapView *mapView;


- (void)showFloorControl;
- (void)showZoomControl;

@end
