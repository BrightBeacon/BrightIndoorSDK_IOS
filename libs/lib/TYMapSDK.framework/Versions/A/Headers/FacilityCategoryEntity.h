//
//  FacilityUIEntity.h
//  TYMapLocationDemo
//
//  Created by innerpeacer on 15/7/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacilityCategoryEntity : NSObject

@property (assign, nonatomic) int facilityCategoryID;
@property (strong, nonatomic) NSString *facilityName;
@property (strong, nonatomic) NSString *facilityImageName;

+ (NSArray *)getAllFacilityCategoryEntities;

@end
