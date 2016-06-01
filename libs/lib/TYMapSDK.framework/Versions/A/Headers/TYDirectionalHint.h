//
//  TYDirectionalString.h
//  MapProject
//
//  Created by innerpeacer on 15/5/5.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "TYLandmark.h"
#import "TYRoutePart.h"

#define INITIAL_EMPTY_ANGLE 1000

/**
    相对方向类型，用于导航提示
 */
typedef enum {
    TYStraight,
    TYTurnRight,
    TYRightForward,
    TYLeftForward,
    TYRightBackward,
    TYLeftBackward,
    TYTurnLeft,
    TYBackward
} TYRelativeDirection;

/**
    导航方向提示，用于导航结果的展示，表示其中的一段
 */
@interface TYDirectionalHint : NSObject

/**
 *  导航方向提示的初始化方法，一般不需要直接调用，由导航管理类调用生成
 *
 *  @param start 当前导航段的起点
 *  @param end   当前导航段的终点
 *  @param angle 前一导航段的方向角
 *
 *  @return 导航方向类实例
 */
- (id)initWithStartPoint:(AGSPoint *)start EndPoint:(AGSPoint *)end PreviousAngle:(double)angle;

/**
 *  当前段起点
 */
@property (nonatomic, strong, readonly) AGSPoint *startPoint;

/**
 *  当前段终点
 */
@property (nonatomic, strong, readonly) AGSPoint *endPoint;

/**
 *  当前段的相对方向
 */
@property (nonatomic, readonly) TYRelativeDirection relativeDirection;

/**
 *  前一段的方向角
 */
@property (nonatomic, readonly) double previousAngle;

/**
 *  当前段的方向角
 */
@property (nonatomic, readonly) double currentAngle;

/**
 *  当前段的长度
 */
@property (nonatomic, readonly) double length;

/**
 *  当前段的路标信息
 */
@property (nonatomic, strong) TYLandmark *landMark;

/**
 *  包含当前段的路径部分
 */
@property (nonatomic, weak) TYRoutePart *routePart;

/**
 *  生成当前段的方向提示
 *
 *  @return 当前的方向提示字符串
 */
- (NSString *)getDirectionString;

/**
 *  生成当前段的路标提示
 *
 *  @return 当前的路径提示字符串
 */
- (NSString *)getLandMarkString;

/**
 *  判断当前段是否有路标信息
 *
 *  @return 是否有路标信息
 */
- (BOOL)hasLandMark;

@end