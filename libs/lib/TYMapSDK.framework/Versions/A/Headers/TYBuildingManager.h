//
//  TYBuildingManager.h
//  MapProject
//
//  Created by innerpeacer on 15/9/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

/**
 *  建筑管理类，用于管理建筑数据
 */
@interface TYBuildingManager : NSObject

/**
 *  解析目标城市的所有建筑信息
 *
 *  @param city 目标城市
 *
 *  @return 建筑信息数组
 */
+ (NSArray *)parseAllBuildings:(TYCity *)city;

/**
 *  解析目标城市特定ID的建筑信息
 *
 *  @param buildingID 目标建筑ID
 *  @param city       目标城市
 *
 *  @return 目标建筑信息
 */
+ (TYBuilding *)parseBuilding:(NSString *)buildingID InCity:(TYCity *)city;

@end
