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

@end
