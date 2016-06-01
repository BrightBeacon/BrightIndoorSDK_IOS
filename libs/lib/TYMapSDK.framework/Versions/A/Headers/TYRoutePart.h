//
//  TYRoutePart.h
//  MapProject
//
//  Created by innerpeacer on 15/5/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TYMapInfo.h"

/**
    路径导航段，用于表示跨层导航中的一段路径
 */
@interface TYRoutePart : NSObject

/**
 *  路径导航段的初始化方法，一般不需要直接调用，由导航管理类调用生成
 *
 *  @param route   导航线
 *  @param mapInfo 导航线所在楼层的地图信息
 *
 *  @return 路径导航类实例
 */
- (id)initWithRouteLine:(AGSPolyline *)route MapInfo:(TYMapInfo *)mapInfo;

@property (nonatomic, assign) int partIndex;

/**
 *  当前段的几何数据
 */
@property (nonatomic, strong, readonly) AGSPolyline *route;

/**
 *  当前段的地图信息
 */
@property (nonatomic, strong, readonly) TYMapInfo *info;

/**
 *  当前段的前一段
 */
@property (nonatomic, weak) TYRoutePart *previousPart;

/**
 *  当前段的下一段
 */
@property (nonatomic, weak) TYRoutePart *nextPart;

/**
 *  判断当前段是否为跨层导航的第一段
 *
 *  @return 是否为第一段
 */
- (BOOL)isFirstPart;

/**
 *  判断当前段是否为跨层导航的最后一段
 *
 *  @return 是否为最后一段
 */
- (BOOL)isLastPart;

/**
 *  判断当前段是否为中间段
 *
 *  @return 是否为中间段
 */
- (BOOL)isMiddlePart;

/**
 *  返回当前段的第一个点
 *
 *  @return 第一个点
 */
- (AGSPoint *)getFirstPoint;

/**
 *  返回当前段的最后一个点
 *
 *  @return 最后一个点
 */
- (AGSPoint *)getLastPoint;

@end
