//
//  TYSearchAdapter.h
//  MapProject
//
//  Created by thomasho on 17/4/26.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoiEntity.h"

@class AGSPoint;

@interface TYSearchAdapter : NSObject


/**
 初始化建筑搜索类

 @param buildingID 建筑ID
 @return 搜索类
 */
- (id)initWithBuildingID:(NSString *)buildingID;

/**
 初始化<=范围(米)去重名建筑类

 @param buildingID 建筑ID
 @param threshold 去除阀值(米)内重复名称的数据
 @return 搜索类
 */
- (id)initWithBuildingID:(NSString *)buildingID distinct:(double)threshold;


/**
 根据自定sql检索POI名称

 @param sql sql语句
 @return POI数组
 */
- (NSArray *)querySql:(NSString *)sql;

/**
 根据关键字模糊检索所有楼层POI名称

 @param searchText 关键字
 @return POI数组
 */
- (NSArray *)queryPoi:(NSString *)searchText;

/**
 根据关键字模糊和楼层检索POI名称

 @param name 检索关键字
 @param floor 楼层
 @return POI数组
 */
- (NSArray *)queryPoi:(NSString *)name andFloor:(int)floor;


/**
 根据类别ID检索所有楼层POI

 @param cids 类别ID；多个以,隔开
 @return POI数组
 */
- (NSArray *)queryPoiByCategoryID:(NSString *)cids;

/**
 根据类别ID和楼层检索POI

 @param cids 类别ID；多个以,隔开
 @param floor 楼层
 @return POI数组
 */
- (NSArray *)queryPoiByCategoryID:(NSString *)cids andFloor:(int)floor;


/**
 搜索point半径约radius范围内floor楼层的poi

 @param point 中心点
 @param radius 半径
 @param floor 楼层，如：-1，1
 @return POI数组
 */
- (NSArray *)queryPoiByCenter:(AGSPoint *)point Radius:(double) radius Floor:(int) floor;
@end
