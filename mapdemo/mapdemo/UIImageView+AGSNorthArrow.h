//
//  UIImageView+AGSNorthArrow.h
//  AGSCommonPatternsSample
//
//  Created by Nicholas Furness on 2/14/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYMapSDK/TYMapSDK.h>

@interface UIImageView (AGSNorthArrow)
@property (nonatomic, weak) IBOutlet TYMapView *mapViewForNorthArrow;
@end
