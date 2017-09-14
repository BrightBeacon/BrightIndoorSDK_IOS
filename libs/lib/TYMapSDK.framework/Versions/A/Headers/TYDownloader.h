//
//  BRTDownloader.h
//  MapProject
//
//  Created by thomasho on 2017/9/12.
//  Copyright © 2017年 BrightBeacon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TYMapInfo,TYBuilding;

@interface TYDownloader : NSObject

/**
 地图数据载入完成回调

 @param building 建筑信息
 @param mapInfos 楼层信息
 @param error 错误信息
 */
typedef void(^OnMapCompletion)(TYBuilding *building,NSArray<TYMapInfo *> *mapInfos, NSError* error);


/**
 加载地图数据

 @param buidingId 建筑ID
 @param aKey 授权APPKEY
 @param completion 完成回调
 */
+ (void)loadMap:(NSString *)buidingId AppKey:(NSString *)aKey OnCompletion:(OnMapCompletion)completion;

@end
