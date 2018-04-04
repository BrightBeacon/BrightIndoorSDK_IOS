//
//  UIImageView+AGSNorthArrow.m
//  AGSCommonPatternsSample
//
//  Created by Nicholas Furness on 2/14/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "UIImageView+AGSNorthArrow.h"
#import <objc/runtime.h>

#define kMapViewKey @"trackingMapView"
#define kAngleKey @"rotationAngle"
#define kTimerKey @"timer"
#define kAnimatingKey @"animating"

@interface UIImageView (AGSNorthArrowInternal)
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation UIImageView (AGSNorthArrow)
#pragma mark - MapView Property
-(void)setMapViewForNorthArrow:(TYMapView *)mapView
{
    TYMapView *oldMapView = self.mapViewForNorthArrow;
    if (oldMapView) {
        // We're watching a new map now. Let's forget the old one.
        [oldMapView removeObserver:self forKeyPath:kAngleKey];
        [oldMapView removeObserver:self forKeyPath:kAnimatingKey];
    }

    // Ensure we are configured properly
    self.userInteractionEnabled = NO;
    self.contentMode = UIViewContentModeScaleAspectFit;

    // Keep a weak reference to the AGSMapView (or nil)
    objc_setAssociatedObject(self, kMapViewKey, mapView, OBJC_ASSOCIATION_ASSIGN);
    
    // Show North
    [self rotateNorthArrow];

    if (mapView) {
        // Track rotation, either through interaction or animation
        [mapView addObserver:self forKeyPath:kAngleKey options:NSKeyValueObservingOptionNew context:nil];
        [mapView addObserver:self forKeyPath:kAnimatingKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(TYMapView *)mapViewForNorthArrow
{
    return objc_getAssociatedObject(self, kMapViewKey);
}

#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAngleKey]) {
        // Simple. The map view's rotation was set directly.
        [self rotateNorthArrow];
    } else if ([keyPath isEqualToString:kAnimatingKey]) {
        // In this case, we're animating to a new rotation. Let's track it and update as we can.
        if (self.mapViewForNorthArrow.animating) {
            // START ANIMATING: We'll use a timer to update the north arrow as the map animates.
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
                                                        selector:@selector(checkRotation:)
                                                        userInfo:nil repeats:YES];
        } else if (self.timer) {
            // STOP ANIMATING: Clear the timer.
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

#pragma mark - Timer event for use during animation
-(void)checkRotation:(NSTimer*)timer
{
    [self rotateNorthArrow];
}

#pragma mark - Rotate ourselves to match the mapView
-(void)rotateNorthArrow
{
    if (self.mapViewForNorthArrow) {
        // We can't just transform the view, because of Auto Layout Constraints.
        // But transforming the view's layer is just fine and dandy.
        double angle = (self.mapViewForNorthArrow.rotationAngle - self.mapViewForNorthArrow.building.initAngle) * M_PI / 180;
        self.layer.transform = CATransform3DMakeRotation(angle, 0, 0, -1);
    } else {
        self.layer.transform = CATransform3DIdentity;
    }
}

#pragma mark - Timer Property for tracking rotation animation
-(void)setTimer:(NSTimer *)timer
{
    objc_setAssociatedObject(self, kTimerKey, timer, timer?OBJC_ASSOCIATION_RETAIN_NONATOMIC:OBJC_ASSOCIATION_ASSIGN);
}

-(NSTimer *)timer
{
    return objc_getAssociatedObject(self, kTimerKey);
}
@end
