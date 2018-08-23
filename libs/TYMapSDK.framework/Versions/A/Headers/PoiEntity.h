//
//  PoiEntity.h
//  TYMapLocationDemo
//
//  Created by innerpeacer on 15/7/27.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiEntity : NSObject

@property (strong, nonatomic) NSString *poiId;
@property (strong, nonatomic) NSString *geoId;
@property (strong, nonatomic) NSString *buildingId;
@property (strong, nonatomic) NSString *floorId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *nameEn;
@property (strong, nonatomic) NSString *retrieval;
@property (strong, nonatomic) NSNumber *categoryId;
@property (strong, nonatomic) NSNumber *labelX;
@property (strong, nonatomic) NSNumber *labelY;
@property (strong, nonatomic) NSNumber *symbolId;
@property (strong, nonatomic) NSNumber *floorNumber;
@property (strong, nonatomic) NSString *floorName;
@property (strong, nonatomic) NSNumber *poiLayer;

@end
