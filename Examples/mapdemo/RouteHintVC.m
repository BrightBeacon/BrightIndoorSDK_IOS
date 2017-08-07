//
//  RouteHintVC.m
//  mapdemo
//
//  Created by thomasho on 2017/8/1.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteHintVC.h"

@interface RouteHintVC () {
    int pointIndex;
    BOOL isStop;
}
@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation RouteHintVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 120)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = @"距离提示";
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"模拟移动" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self initSymbols];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isStop = YES;
}

- (void)initSymbols
{
    //初始化路径图标
    AGSPictureMarkerSymbol *startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeStart"];
    startSymbol.offset = CGPointMake(0, 22);
    
    AGSPictureMarkerSymbol *endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeEnd"];
    endSymbol.offset = CGPointMake(0, 22);
    
    AGSPictureMarkerSymbol *switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"routeSwitch"];
    
    AGSSimpleMarkerSymbol *markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
    
    
    //设置地图显示定位图标
    AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
}

- (IBAction)moveButtonClicked:(id)sender {
    TYRouteResult *rs = self.mapView.routeResult;
    TYRoutePart *part = [rs getRoutePartsOnFloor:self.mapView.routeStart.floor].firstObject;
    if (part == nil) {
        return;
    }
    AGSPoint *pt = [part.route pointOnPath:0 atIndex:0];
    TYLocalPoint *lp = [self p2lp:pt];
    [self moveToLocalPoint:lp];
}


- (void)moveToLocalPoint:(TYLocalPoint *)lp {
    if (lp.floor != self.mapView.currentMapInfo.floorNumber) {
        [self.mapView setFloor:@(lp.floor).stringValue];
    }
    [self.mapView showLocation:lp];
    [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:lp];
    
    TYRouteResult *rs = self.mapView.routeResult;
    if ([rs distanceToRouteEnd:lp] < 0.5) {
        return;
    }
    
    TYRoutePart *part = [rs getNearestRoutePart:lp];
    if (part == nil) {
        return;
    }
    AGSPolyline *line = part.route;
    AGSPoint *pt = [line pointOnPath:0 atIndex:pointIndex++];
    int floor = part.info.floorNumber;
    if ([pt isEqual:part.getLastPoint]) {
        pointIndex = 0;
        if (part.isLastPart) {
            //...
        }else {
            TYRoutePart *nextPart = part.nextPart;
            pt = nextPart.getFirstPoint;
            floor = nextPart.info.floorNumber;
            if (floor != self.mapView.currentMapInfo.floorNumber) {
                [self.mapView setFloorWithInfo:nextPart.info];
            }
        }
    }
    TYLocalPoint *tmp = [TYLocalPoint pointWithX:pt.x Y:pt.y Floor:floor];
    [self animateUpdateGraphic:0 start:lp end:tmp];
    
    NSArray *hints = [rs getRouteDirectionalHint:part];
    TYDirectionalHint *hint = [rs getDirectionHintForLocation:tmp FromHints:hints];
    if (hint) {
        [self.mapView setRotationAngle: hint.currentAngle animated:YES];
        [self.mapView processDeviceRotation:hint.currentAngle-self.mapView.building.initAngle];
        [self.mapView showRouteHintForDirectionHint:hint Centered:NO];
    }
}

- (void)animateUpdateGraphic:(double)offset start:(TYLocalPoint *)start end:(TYLocalPoint *)end {
    if (isStop) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            double distance = [start distanceWith:end];
            if (distance >0 && offset < distance) {
                double scale = offset/distance;
                double x = start.x * (1 - scale) + end.x * scale;
                double y = start.y * (1 - scale) + end.y * scale;
                AGSPoint *pt = [AGSPoint pointWithX:x y:y spatialReference:self.mapView.spatialReference];
                [self.mapView centerAtPoint:pt animated:NO];
                [self showCurrentHint:[self p2lp:pt]];
                [self.mapView showLocation:[self p2lp:pt]];
                [self animateUpdateGraphic:offset+0.1 start:start end:end];
            }else {
                [self showCurrentHint:end];
                [self moveToLocalPoint:end];
            }
        });
    });
}

- (void)showCurrentHint:(TYLocalPoint *)lp {
    TYRoutePart *part = [self.mapView.routeResult getNearestRoutePart:lp];
    if (part) {
        NSArray *hints = [self.mapView.routeResult getRouteDirectionalHint:part];
        TYDirectionalHint *hint = [self.mapView.routeResult getDirectionHintForLocation:lp FromHints:hints];
        if (hint) {
            self.tipsLabel.text = [NSString stringWithFormat:@"方向：%@\n本段长度%.2f\n本段角度%.2f\n剩余/全长：%.2f/%.2f",hint.getDirectionString,hint.length,hint.currentAngle,[self.mapView.routeResult distanceToRouteEnd:lp],self.mapView.routeResult.length];
        }
    }
}

#pragma mark - **************** 地图点击

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
    if (!poi) {
        self.tipsLabel.text = @"请选择有POI范围的点";
        return;
    }
    if (self.mapView.routeStart == nil) {
        [self.mapView showRouteStartSymbolOnCurrentFloor:[self p2lp:mappoint]];
    }else {
        [self.mapView showRouteEndSymbolOnCurrentFloor:[self p2lp:mappoint]];
        [mapView.routeManager requestRouteWithStart:self.mapView.routeStart End:self.mapView.routeEnd];
    }
}

- (TYLocalPoint *)p2lp:(AGSPoint *)pt {
    return [TYLocalPoint pointWithX:pt.x Y:pt.y Floor:self.mapView.currentMapInfo.floorNumber];
}

//楼层加载回调；如果已有路径规划，显示本层规划，并缩放全屏显示
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    if (self.mapView.routeResult) {
        [self.mapView showRouteResultOnCurrentFloor];
        [self.mapView zoomToResolution:mapInfo.mapSize.x/self.mapView.frame.size.width withCenterPoint:mapView.baseLayer.fullEnvelope.center animated:YES];
    }
}

#pragma mark - **************** 路径规划回调
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs {
    [self.mapView setRouteStart:self.mapView.routeStart];
    [self.mapView setRouteEnd:self.mapView.routeEnd];
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
    self.tipsLabel.text = [NSString stringWithFormat:@"全长%.2f米;",rs.length];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@",error);
    }
    [self.mapView resetRouteLayer];
}
@end
