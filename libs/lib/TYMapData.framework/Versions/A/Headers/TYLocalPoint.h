#import <Foundation/Foundation.h>

#define LARGE_DISTANCE 100000000

/**
 *  位置点类
 */
@interface TYLocalPoint : NSObject

/**
 *  x坐标
 */
@property (readonly) double x;

/**
 *  y坐标
 */
@property (readonly) double y;

/**
 *  位置点所在楼层
 */
@property (assign) int floor;

/**
 *  位置点的静态实例化方法
 *
 *  @param x x坐标
 *  @param y y坐标
 *
 *  @return 位置点实例
 */
+ (TYLocalPoint *)pointWithX:(double)x Y:(double)y;

/**
 *  位置点的静态实例化方法
 *
 *  @param x x坐标
 *  @param y y坐标
 *  @param f 位置点所在楼层
 *
 *  @return 位置点实例
 */
+ (TYLocalPoint *)pointWithX:(double)x Y:(double)y Floor:(int)f;

/**
 *  计算当前点P到特定点P'的直线距离
 *
 *  @param p 特定点P'
 *
 *  @return 同层两点间直线距离
 */
- (double)distanceWith:(TYLocalPoint *)p;

/**
 *  计算两点P1、P2间的距离
 *
 *  @param p1 点P1
 *  @param p2 点P2
 *
 *  @return 两点间距离
 */
+ (double)distanceBetween:(TYLocalPoint *)p1 and:(TYLocalPoint *)p2;

@end
