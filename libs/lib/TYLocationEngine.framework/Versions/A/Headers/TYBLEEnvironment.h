//
//  TYBLEEnvironment.h
//  BLEProject
//
//  Created by innerpeacer on 16/6/17.
//  Copyright © 2016年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
    定位环境设置类
 */
@interface TYBLEEnvironment : NSObject


/**
 设置定位数据自定义目录，需目录可写入。(有默认值)

 @param dir 自定义目录
 */
+ (void)setRootDirectoryForFiles:(NSString *)dir;


/**
 获取定位目录

 @return 目录路径
 */
+ (NSString *)getRootDirectoryForFiles;


/**
 定位SDK版本

 @return 版本号
 */
+ (NSString *)getSDKVersion;


/**
 设置定位权限，默认请求一直需要

 @param whenInUse 是否仅使用时期间定位权限
 */
+ (void)setRequestWhenInUseAuthorization:(BOOL)whenInUse;


/**
 获取定位权限模式

 @return @YES 仅在使用期间 @NO 一直需要
 */
+ (BOOL)isWhenInUseAuthorization;
@end
