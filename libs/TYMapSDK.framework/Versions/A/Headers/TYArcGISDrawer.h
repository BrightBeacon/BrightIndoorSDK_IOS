//
//  TYArcGISDrawer.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface TYArcGISDrawer : NSObject

+ (void)drawPoint:(AGSPoint *)p AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color;

+ (void)drawPoint:(AGSPoint *)p AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color Size:(CGSize)size;

+ (void)drawPoint:(AGSPoint *)p AtLayer:(AGSGraphicsLayer *)layer WithBuffer1:(double)buffer1 Buffer2:(double)buffer2;

+ (void)drawLineFrom:(AGSPoint *)start To:(AGSPoint *)end AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color Width:(CGFloat)width spatialReference:(AGSSpatialReference *)spatialReference;
+ (void)drawString:(NSString *)s Position:(AGSPoint *)point AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawCircleCenterAt:(AGSPoint *)center Radius:(double)r AtLayer:(AGSGraphicsLayer *)layer WithColor:(UIColor *)color;
+ (void)drawPictureSymbol:(AGSPictureMarkerSymbol *)pms At:(AGSPoint *)point AtLayer:(AGSGraphicsLayer *)layer;

+ (void)drawPolygon:(NSArray *)points AtLayer:(AGSGraphicsLayer *)layer Color:(UIColor *)color spatialReference:(AGSSpatialReference *)spatialReference;


@end