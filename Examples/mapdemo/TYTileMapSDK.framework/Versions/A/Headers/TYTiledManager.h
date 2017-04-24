//
//  TYTiledManager.h
//  CustomTiledLayerSample
//
//  Created by innerpeacer on 16/8/20.
//
//

#import <Foundation/Foundation.h>
#import "TYTiledLayer.h"

@interface TYTiledManager : NSObject

/**
 默认从path获取数据，如无则从url同步下载

 @param server 服务器地址
 @param buildingId 建筑id
 @param path 本地文件路径
 @return 瓦片楼层描述数据
 */
+ (NSArray *)tileInfoByServer:(NSString *)server buildingId:(NSString *)buildingId toPath:(NSString *)path;


/**
 通过mapID索引到瓦片当层数据

 @param tileInfos 所有瓦片数据
 @param mapID 楼层ID
 @return 当层瓦片数据
 */
+ (NSDictionary *)findTileInfo:(NSArray *)tileInfos byMapID:(NSString *)mapID;
@end
