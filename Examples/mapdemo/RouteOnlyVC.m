//
//  RouteOnlyVC.m
//  mapdemo
//
//  Created by thomasho on 2017/9/13.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteOnlyVC.h"
#import <TYMapSDK/TYMapSDK.h>
#import <TYMapData/TYMapData.h>

@interface RouteOnlyVC()<TYOfflineRouteManagerDelegate> {
    TYLocalPoint *startP;
}
@end

//演示不需要显示地图，只路径规划方法
@implementation RouteOnlyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *lbl = [[UILabel alloc] initWithFrame:[UIScreen mainScreen].bounds];
    lbl.text = @"不需要显示地图，只使用数据，详情查看代码";
    [self.view addSubview:lbl];
    [TYDownloader loadMap:kBuildingId AppKey:kAppKey OnCompletion:^(TYBuilding *building, NSArray<TYMapInfo *> *mapInfos, NSError *error) {
        if (building) {
            [self initRoute:building info:mapInfos];
        }
    }];
}

- (void)initRoute:(TYBuilding *)building info:(NSArray <TYMapInfo *> *)mapinfos {
    TYOfflineRouteManager *rm = [TYOfflineRouteManager routeManagerWithBuilding:building MapInfos:mapinfos];
    rm.delegate = self;
    startP = [TYLocalPoint pointWithX:13532005.693566 Y:3639175.863626 Floor:1];
    [rm requestRouteWithStart:startP End:[TYLocalPoint pointWithX:13532014.059454 Y:3639181.011865 Floor:1]];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs {
    TYRoutePart *part = rs.allRoutePartArray.firstObject;
    do {
        NSArray<TYDirectionalHint *> *hints = [rs getRouteDirectionalHint:part distanceThrehold:0 angleThrehold:0];
        TYDirectionalHint *hint = [rs getDirectionHintForLocation:startP FromHints:hints];
        do {
            NSLog(@"-%@",[hint getDirectionString]);
            hint = hint.nextHint;
        } while (hint);
        NSLog(@"以上为%@层路径：%@",part.info.floorName,part.description);
        part = part.nextPart;
    } while (part);
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    NSLog(@"%@",error);
}

@end
