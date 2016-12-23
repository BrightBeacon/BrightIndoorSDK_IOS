//
//  LocDataSync.h
//  mapdemo
//
//  Created by thomasho on 16/12/17.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>

#define url_beaconnew @"http://service.map.brtbeacon.com/mobile/data/load/beacon/new?buildingID=%@&appkey=%@&license=%@"

typedef void(^locDataCompletion)(NSError *err);

@interface LocDataSync : NSObject

+ (void)updateLocData:(NSString *)url onCompletion:(locDataCompletion)block;
+ (BOOL)unzipFile:(NSString *)zipPath toDir:(NSString *)dir;
@end
