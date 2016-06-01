//
//  TYOfflineRouteManager.h
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TYRouteResult.h"
#import <TYMapData/TYMapData.h>
#import "TYPoint.h"
#import <ArcGIS/ArcGIS.h>

@class TYOfflineRouteManager;

/**
 *  离线路径管理代理协议
 */
@protocol TYOfflineRouteManagerDelegate <NSObject>

/**
 *  解决路径规划返回方法
 *
 *  @param routeManager 离线路径管理实例
 *  @param rs           路径规划结果
 */
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs;

/**
 *  路径规划失败回调方法
 *
 *  @param routeManager 离线路径管理实例
 *  @param error        错误信息
 */
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error;

@end


/**
 *  离线路径管理类
 */
@interface TYOfflineRouteManager : NSObject

/**
 *  路径规划起点
 */
@property (nonatomic, strong, readonly) TYPoint *startPoint;

/**
 *  路径规划终点
 */
@property (nonatomic, strong, readonly) TYPoint *endPoint;


/**
 *  离线路径管理代理
 */
@property (nonatomic, weak) id<TYOfflineRouteManagerDelegate> delegate;

/**
 *  离线路径管理类的静态实例化方法
 *
 *  @param building     目标建筑
 *  @param mapInfoArray 目标建筑的所有楼层信息
 *
 *  @return 离线路径管理类实例
 */
+ (TYOfflineRouteManager *)routeManagerWithBuilding:(TYBuilding *)building MapInfos:(NSArray *)mapInfoArray;


/**
 *  请求路径规划，在代理方法获取规划结果
 *
 *  @param start 路径规划起点
 *  @param end   路径规划终点
 */
- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end;

@end
