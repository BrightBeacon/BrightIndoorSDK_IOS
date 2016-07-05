//
//  TYMapCredential.h
//  MapProject
//
//  Created by innerpeacer on 15/11/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYMapCredential : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *buildingID;
@property (nonatomic, strong, readonly) NSString *license;

+ (TYMapCredential *)credentialWithUserID:(NSString *)uid BuildingID:(NSString *)bid License:(NSString *)l;
- (NSDictionary *)buildDictionary;

@end