//
//  TYBLEEnvironment.h
//  BLEProject
//
//  Created by innerpeacer on 16/6/17.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYBLEEnvironment : NSObject

+ (void)setRootDirectoryForFiles:(NSString *)dir;
+ (NSString *)getRootDirectoryForFiles;


+ (NSString *)getSDKVersion;
+ (NSString *)getLibraryVersion;


/**
 设置定位权限，默认请求一直需要

 @param whenInUse 是否仅使用时定位
 */
+ (void)setRequestWhenInUseAuthorization:(BOOL)whenInUse;
+ (BOOL)isWhenInUseAuthorization;
@end
