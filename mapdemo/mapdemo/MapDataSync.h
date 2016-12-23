//
//  BRTMapDataSync.h
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>

#define url_mapnew @"http://service.map.brtbeacon.com/mobile/data/load/mapdata/new?buildingID=%@&appkey=%@&license=%@"

typedef void(^mapDataCompletion)(NSError *err);

@interface MapDataSync : NSObject

+ (void)updateMapData:(NSString *)url onCompletion:(mapDataCompletion)block;
+ (BOOL)unzipFile:(NSString *)zipPath toDir:(NSString *)dir;
@end
