//
//  TYRouteManager.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TYMapEnviroment.h"
#import "TYRouteResult.h"

#import <TYMapData/TYMapData.h>
#import "TYPoint.h"

@class TYRouteManager;

/**
 *  路径管理代理协议
 */
@protocol TYRouteManagerDelegate <NSObject>

/**
 *  获取默认参数失败回调方法
 *
 *  @param routeManager 路径管理实例
 *  @param error        错误信息
 */
- (void)routeManager:(TYRouteManager *)routeManager didFailRetrieveDefaultRouteTaskParametersWithError:(NSError *)error;

/**
 *  解决路径规划返回方法
 *
 *  @param routeManager       路径管理实例
 *  @param routeResult 路径规划结果
 */
- (void)routeManager:(TYRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)routeResult;


/**
 *  路径规划失败回调方法
 *
 *  @param routeManager 路径管理实例
 *  @param error        错误信息
 */
- (void)routeManager:(TYRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error;

/**
 *  路径规划获取默认参数回调
 *
 *  @param routeManager 路径管理实例
 */
- (void)routeManagerDidRetrieveDefaultRouteTaskParameters:(TYRouteManager *)routeManager;

@end

/**
 *  路径管理类
 */
@interface TYRouteManager : NSObject

/**
 *  路径规划起点
 */
@property (nonatomic, strong, readonly) TYPoint *startPoint;

/**
 *  路径规划终点
 */
@property (nonatomic, strong, readonly) TYPoint *endPoint;

/**
 *  路径管理代理
 */
@property (nonatomic, weak) id<TYRouteManagerDelegate> delegate;

/**
 *  路径管理类的静态实例化方法
 *
 *  @param building     目标建筑
 *  @param credential   用户访问验证
 *  @param mapInfoArray 目标建筑的所有楼层信息
 *
 *  @return 路径管理类实例
 */
+ (TYRouteManager *)routeManagerWithBuilding:(TYBuilding *)building credential:(TYCredential *)credential MapInfos:(NSArray *)mapInfoArray;

/**
 *  请求路径规划，在代理方法获取规划结果
 *
 *  @param start 路径规划起点
 *  @param end   路径规划终点
 */
- (void)requestRouteWithStart:(TYLocalPoint *)start End:(TYLocalPoint *)end;


@end

