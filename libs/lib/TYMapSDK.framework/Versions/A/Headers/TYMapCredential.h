//
//  TYMapCredential.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultLicense @"00000000000000000000000000000000"

@interface TYMapCredential : NSObject

@property (nonatomic, strong, readonly) NSString *appKey;
@property (nonatomic, strong, readonly) NSString *buildingID;
@property (nonatomic, strong, readonly) NSString *license;

+ (TYMapCredential *)credentialWithAppKey:(NSString *)aKey BuildingID:(NSString *)bid License:(NSString *)license;
- (NSDictionary *)buildDictionary;
- (void)resetLicense;
      
@end
