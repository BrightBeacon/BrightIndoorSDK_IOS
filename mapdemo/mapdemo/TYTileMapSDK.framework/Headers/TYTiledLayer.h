//
//  TYTiledLayer.h
//  CustomTiledLayerSample
//
//  Created by innerpeacer on 16/8/19.
//
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>


@interface TYTiledLayer : AGSTiledServiceLayer

/**
 生成瓦片Layer

 @param tileRoot 本地瓦片目录
 @param infoDict 瓦片楼层数据
 @return 瓦片Layer
 */
- (instancetype)initWithTileRoot:(NSString *)tileRoot withTileInfo:(NSDictionary *)infoDict;

/**
 移除本地缓存瓦片，下次重新通过url请求。
 */
- (void)removeTileCache;

/**
 在线瓦片图片url前缀
 */
@property (nonatomic,strong) NSString *imageBaseUrl;

@end
