//
//  TYMapCredential.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapError.h"

#define kDefaultLicense @"00000000000000000000000000000000"

@interface TYMapCredential : NSObject

+ (TYMapError)checkAppKey:(NSString *)aKey BuildingID:(NSString *)bid License:(NSString *)license;
+ (void)saveAppKey:(NSString *)aKey BuildingID:(NSString *)bid License:(NSString *)license;
+ (void)resetAppKey:(NSString *)aKey BuildingID:(NSString *)bid;

+ (NSString *)urlEncodeLicense:(NSString *)license;
+ (NSString *)urlDecodeLicense:(NSString *)license;
@end
