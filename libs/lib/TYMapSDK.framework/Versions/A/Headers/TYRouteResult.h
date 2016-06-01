//
//  TYRouteResult.h
//  MapProject
//
//  Created by innerpeacer on 15/5/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYRoutePart.h"
#import "TYDirectionalHint.h"

/**
 *  路径规划结果
 */
@interface TYRouteResult : NSObject

/**
 *  路径结果的所有路径段
 */
@property (nonatomic, readonly) NSArray *allRoutePartArray;

/**
 *  路径结果按楼层分类的映射关系
 */
@property (nonatomic, readonly) NSDictionary *allFloorRoutePartDict;

/**
 *  路径结果的类实例化方法，一般不需要直接调用，由导航管理类调用生成
 *
 *  @param routePartArray 路径段数组
 *
 *  @return 路径结果实例
 */
+ (TYRouteResult *)routeResultWithRouteParts:(NSArray *)routePartArray;

/**
 *  判断位置位置点是否偏离导航线
 *
 *  @param point    目标位置点
 *  @param distance 判断是否偏离的阈值
 *
 *  @return 是否偏离导航线
 */
- (BOOL)isDeviatingFromRoute:(TYLocalPoint *)point WithThrehold:(double)distance;

/**
 *  获取距离目标位置点最近的路径段
 *
 *  @param location 目标位置点
 *
 *  @return 最近的路径段
 */
- (TYRoutePart *)getNearestRoutePart:(TYLocalPoint *)location;

/**
 *  获取目标楼层的所有路径段
 *
 *  @param floor 目标楼层
 *
 *  @return 路径段数组
 */
- (NSArray *)getRoutePartsOnFloor:(int)floor;

/**
 *  从路径段数组中获取特定索引的路径段
 *
 *  @param index 目标段索引
 *
 *  @return 目标段
 */
- (TYRoutePart *)getRoutePart:(int)index;

/**
 *  获取目标路径段的导航提示
 *
 *  @param rp 目标路径段
 *
 *  @return 目标路径段的导航提示
 */
- (NSArray *)getRouteDirectionalHint:(TYRoutePart *)rp;

/**
 *  从一组导航提示中获取与目标位置点对应的导航提示
 *
 *  @param location   目标位置点
 *  @param directions 目标导航提示数组
 *
 *  @return 与目标位置点对应的导航提示
 */
- (TYDirectionalHint *)getDirectionHintForLocation:(TYLocalPoint *)location FromHints:(NSArray *)directions;

/**
 *  获取一组折线的子折线
 *
 *  @param originalLine 原折线
 *  @param start        子折线起点
 *  @param end          子折线终点
 *
 *  @return 目标子折线
 */
+ (AGSPolyline *)getSubPolyline:(AGSPolyline *)originalLine WithStart:(AGSPoint *)start End:(AGSPoint *)end;

@end