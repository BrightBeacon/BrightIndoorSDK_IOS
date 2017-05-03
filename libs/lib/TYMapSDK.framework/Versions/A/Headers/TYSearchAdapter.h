//
//  TYSearchAdapter.h
//  MapProject
//
//  Created by thomasho on 17/4/26.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoiEntity.h"

@interface TYSearchAdapter : NSObject

- (id)initWithBuildingID:(NSString *)buildingID;



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
 @param floorNumber 楼层
 @return POI数组
 */
- (NSArray *)queryPoi:(NSString *)name andFloor:(int)floorNumber;


/**
 根据类别ID检索所有楼层POI

 @param cids 类别ID；多个以,隔开
 @return POI数组
 */
- (NSArray *)queryPoiByCategoryID:(NSString *)cids;

/**
 根据类别ID和楼层检索POI

 @param cids 类别ID；多个以,隔开
 @param floorNumber 楼层
 @return POI数组
 */
- (NSArray *)queryPoiByCategoryID:(NSString *)cids andFloor:(int)floorNumber;
@end
