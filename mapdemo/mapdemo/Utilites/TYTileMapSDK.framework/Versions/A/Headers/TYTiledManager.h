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

@property (nonatomic,assign) BOOL isLoad;
@property (nonatomic,strong) NSArray *allTileInfo;

/**
 默认从本地获取数据，如无则从url下载

 @param buildingId 建筑id
 @return 瓦片楼层描述数据
 */
- (instancetype)initWithBuilding:(NSString *)buildingId;


/**
 通过楼层名索引到瓦片数据

 @param floorName 楼层名
 @return 当层瓦片数据
 */
- (NSDictionary *)tileInfoByFloor:(NSString *)floorName;

@end
