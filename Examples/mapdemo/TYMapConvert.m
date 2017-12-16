//
//  TYMapConvert.m
//  TYMapConvert
//
//  Created by thomasho on 17/6/16.
//  Copyright © 2017年. All rights reserved.
//

#import "TYMapConvert.h"

@implementation TYMapConvert

#define p(arr,i) [arr[i] doubleValue]
+ (CGPoint)convert:(NSArray *)from to:(NSArray *)to x:(double)x y:(double)y;
{
    double delta_x = x - p(from, 0);
    double delta_y = y - p(from, 1);
    double TY_DELTA_1_X = p(from, 2) - p(from, 0);
    double TY_DELTA_1_Y = p(from, 3) - p(from, 1);
    double TY_DELTA_2_X = p(from, 4) - p(from, 0);
    double TY_DELTA_2_Y = p(from, 5) - p(from, 1);
    
    double lamda = (delta_x * TY_DELTA_2_Y - delta_y * TY_DELTA_2_X) / (TY_DELTA_1_X * TY_DELTA_2_Y - TY_DELTA_1_Y * TY_DELTA_2_X);
    double miu = (delta_x * TY_DELTA_1_Y - delta_y * TY_DELTA_1_X) / (TY_DELTA_2_X * TY_DELTA_1_Y - TY_DELTA_1_X * TY_DELTA_2_Y);
    
    
    double THD_MAP_X0 = p(to, 0);
    double THD_MAP_Y0 = p(to, 1);
    double THD_DELTA_1_X = p(to, 2) - p(to, 0);
    double THD_DELTA_1_Y = p(to, 3) - p(to, 1);
    double THD_DELTA_2_X = p(to, 4) - p(to, 0);
    double THD_DELTA_2_Y = p(to, 5) - p(to, 1);
    double thd_x = THD_MAP_X0 + lamda * THD_DELTA_1_X + miu * THD_DELTA_2_X;
    double thd_y = THD_MAP_Y0 + lamda * THD_DELTA_1_Y + miu * THD_DELTA_2_Y;
    return CGPointMake(thd_x, thd_y);
}

@end
