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
@property (assign, nonatomic) int categoryId;
@property (assign, nonatomic) double labelX;
@property (assign, nonatomic) double labelY;
@property (assign, nonatomic) int symbolID;
@property (assign, nonatomic) int floorNumber;
@property (strong, nonatomic) NSString *floorName;
@property (assign, nonatomic) int layer;

@end
