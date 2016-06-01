//
//  TYPoi.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYGeometry.h"
/**
 *  POI所在层，当前按层来分类：房间层（ROOM）、资产层（ASSET）、公共设施层（FACILITY）
 */
typedef enum
{
    POI_ROOM = 1,
    POI_ASSET = 2,
    POI_FACILITY = 3
} POI_LAYER;

/**
 *  POI类：用于表示POI相关数据，主要包含POI地理信息，及相应POI ID
 */
@interface TYPoi : NSObject

/**
 *  POI地理ID
 */
@property (nonatomic, strong) NSString *geoID;

/**
 *  POI ID
 */
@property (nonatomic, strong) NSString *poiID;

/**
 *  POI所在楼层ID
 */
@property (nonatomic, strong) NSString *floorID;

/**
 *  POI所在建筑ID
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 *  POI名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  POI几何数据
 */
@property (nonatomic, strong) TYGeometry *geometry;

/**
 *  POI分类类型ID
 */
@property (nonatomic, readonly) int categoryID;

/**
 *  POI所在层
 */
@property (nonatomic, readonly) POI_LAYER layer;

/**
 *  创建POI实例的静态方法
 *
 *  @param gid      地理ID
 *  @param pid      POI ID
 *  @param fid      楼层ID
 *  @param bid      建筑ID
 *  @param pname    POI名称
 *  @param geometry POI位置
 *  @param cid      POI类型
 *  @param pLayer   POI所在层
 *
 *  @return POI实例
 */
+ (TYPoi *)poiWithGeoID:(NSString *)gid PoiID:(NSString *)pid FloorID:(NSString *)fid  BuildingID:(NSString *)bid Name:(NSString *)pname Geometry:(TYGeometry *)geometry CategoryID:(int)cid Layer:(POI_LAYER)pLayer;

@end
