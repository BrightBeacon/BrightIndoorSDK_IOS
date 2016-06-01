//
//  TYLandMark.h
//  MapProject
//
//  Created by innerpeacer on 15/5/6.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TYMapData/TYMapData.h>

/**
 *  路标类，用于导航的提示
 */
@interface TYLandmark : NSObject

/**
 *  当前路标的名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  当前路标的位置
 */
@property (nonatomic, strong) TYLocalPoint *location;

@end
