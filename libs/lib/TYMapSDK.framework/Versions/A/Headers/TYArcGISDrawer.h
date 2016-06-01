//
//  TYArcGISDrawer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TYPoint.h"
#import "TYGraphicsLayer.h"
#import "TYSpatialReference.h"
#import "TYPictureMarkerSymbol.h"

@interface TYArcGISDrawer : NSObject

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color;

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color Size:(CGSize)size;

+ (void)drawPoint:(TYPoint *)p AtLayer:(TYGraphicsLayer *)layer WithBuffer1:(double)buffer1 Buffer2:(double)buffer2;

+ (void)drawLineFrom:(TYPoint *)start To:(TYPoint *)end AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color Width:(CGFloat)width spatialReference:(TYSpatialReference *)spatialReference;
+ (void)drawString:(NSString *)s Position:(TYPoint *)point AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawCircleCenterAt:(TYPoint *)center Radius:(double)r AtLayer:(TYGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawPictureSymbol:(TYPictureMarkerSymbol *)pms At:(TYPoint *)point AtLayer:(TYGraphicsLayer *)layer;

+ (void)drawPolygon:(NSArray *)points AtLayer:(TYGraphicsLayer *)layer Color:(UIColor *)color spatialReference:(TYSpatialReference *)spatialReference;


@end