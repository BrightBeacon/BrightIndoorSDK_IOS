//
//  TYMapConvert.h
//  TYMapConvert
//
//  Created by thomasho on 17/1/16.
//  Copyright © 2017年 TYMapConvert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TYMapConvert : NSObject


/**
 * 通过给定3组基点数据进行地图坐标转换
 *
 * @param from 待转换坐标基点，3组
 * @param to 目标坐标基点，3组
 * @param x 待转换x
 * @param y 待转换y
 * @return 目标坐标
 */
+ (CGPoint)convert:(NSArray *)from to:(NSArray *)to x:(double)x y:(double)y;

@end
