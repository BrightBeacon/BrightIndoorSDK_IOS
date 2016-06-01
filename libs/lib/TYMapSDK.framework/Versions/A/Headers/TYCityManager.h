//
//  TYCityManager.h
//  MapProject
//
//  Created by innerpeacer on 15/9/8.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

/**
 *  城市管理类，用于管理城市数据
 */
@interface TYCityManager : NSObject

/**
 *  解析所有城市信息列表
 *
 *  @return 所有城市信息数组
 */
+ (NSArray *)parseAllCities;

/**
 *  解析目标城市信息
 *
 *  @param cityID 目标城市ID
 *
 *  @return 目标城市信息
 */
+ (TYCity *)parseCity:(NSString *)cityID;

@end
