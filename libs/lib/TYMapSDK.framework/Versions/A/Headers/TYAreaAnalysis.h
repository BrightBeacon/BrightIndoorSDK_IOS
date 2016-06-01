//
//  TYAreaAnalysis.h
//  MapProject
//
//  Created by innerpeacer on 15/3/24.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYAreaAnalysis : NSObject

@property (nonatomic, assign) double buffer;
@property (nonatomic, readonly) int areaCount;

- (id)initWithPath:(NSString *)path;
- (NSArray *)extractAOIWithX:(double)x Y:(double)y;

@end
