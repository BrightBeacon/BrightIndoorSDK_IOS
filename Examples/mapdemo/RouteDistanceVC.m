//
//  RouteDistanceVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteDistanceVC.h"

@interface RouteDistanceVC ()

@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation RouteDistanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 120)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = @"距离提示";
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"模拟位置" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self initSymbols];
}

//初始化路径图标
- (void)initSymbols
{
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
}

//自定义路径符号
- (void)customRouteSymbols {
    {
        AGSCompositeSymbol *passedCS = [AGSCompositeSymbol compositeSymbol];
        
        AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
        //        sls1.color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        sls1.color = [UIColor colorWithRed:0x3f/255.0f green:0x87/255.0f blue:0xad/255.0f alpha:1.0f];
        sls1.style = AGSSimpleLineSymbolStyleSolid;
        sls1.width = 9;
        [passedCS addSymbol:sls1];
        
        AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
        sls2.color = [UIColor colorWithRed:0x3f/255.0f green:0x87/255.0f blue:0xad/255.0f alpha:1.0f];
        sls2.style = AGSSimpleLineSymbolStyleSolid;
        sls2.width = 6;
        [passedCS addSymbol:sls2];
        
        [self.mapView setPassedRouteSymbol:passedCS];
    }
    
    
    
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor colorWithRed:0x3f/255.0f green:0x87/255.0f blue:0xad/255.0f alpha:1.0f];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor colorWithRed:0x49/255.0f green:0xb9/255.0f blue:1 alpha:1.0f];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 6;
    [cs addSymbol:sls2];
    [self.mapView setRouteSymbol:cs];
}

- (IBAction)moveButtonClicked:(id)sender {
    TYRouteResult *rs = self.mapView.routeResult;
    TYRoutePart *part = [rs getRoutePartsOnFloor:self.mapView.currentMapInfo.floorNumber].firstObject;
    if (part == nil) {
        return;
    }
    //随机获取本层路径点（缩放、居中、显示该点、显示经过/剩余路段）
    AGSPoint *pt = [part.route pointOnPath:0 atIndex:arc4random()%part.route.numPoints];
    TYLocalPoint *lp = [self p2lp:pt];
    [self.mapView zoomToGeometry:part.route withPadding:0 animated:YES];
    [self.mapView centerAtPoint:pt animated:YES];
    [self.mapView showLocation:lp];
    [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:lp];
    
    //获取路径、路段长度、方向提示信息
    CGFloat total = rs.length;
    CGFloat remaining = [rs distanceToRouteEnd:lp];
    CGFloat currentPartLen = [[AGSGeometryEngine defaultGeometryEngine] lengthOfGeometry:part.route];
    
    //hint为当前段路径提示信息；默认会忽略小于6米和小于15度的路径。
    TYDirectionalHint *hint = [self.mapView.routeResult getDirectionHintForLocation:lp FromHints:[self.mapView.routeResult getRouteDirectionalHint:part distanceThrehold:2 angleThrehold:10]];
    [self.mapView showRouteHintForDirectionHint:hint Centered:NO];
    CGFloat currentHintLen = hint.length;
    CGFloat currentHintRemaining = [lp distanceWith:[self p2lp:hint.endPoint]];
    CGFloat nextHintLen = hint.nextHint.length;
    
    self.tipsLabel.text = [NSString stringWithFormat:@"全长%.2f米\n总剩余：%.2f米\n本层路径长：%.2f米\n当前路段总长(约)：%.2f米\n当前路段剩余：%.2f米\n当前路段方向：%@\n下一段总长：%.2f米\n下一段方向：%@",total,remaining,currentPartLen,currentHintLen,currentHintRemaining,hint.getDirectionString,nextHintLen,hint.nextHint.getDirectionString];
}

- (TYLocalPoint *)p2lp:(AGSPoint *)pt {
    return [TYLocalPoint pointWithX:pt.x Y:pt.y Floor:self.mapView.currentMapInfo.floorNumber];
}

//地图点击事件；选取、设置起点和终点
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    if ([mapView.baseLayer.fullEnvelope containsPoint:mappoint] == NO) {
        self.tipsLabel.text = @"请选择地图内的点";
        return;
    }
    if (self.mapView.routeStart == nil) {
        [self.mapView setRouteStart:[self p2lp:mappoint]];
        [self.mapView showRouteStartSymbolOnCurrentFloor:self.mapView.routeStart];
    }else {
        [self.mapView setRouteEnd:[self p2lp:mappoint]];
        [self.mapView showRouteEndSymbolOnCurrentFloor:[self p2lp:mappoint]];
        
        //清除线
        [self.mapView clearRouteLayer];
        [mapView.routeManager requestRouteWithStart:self.mapView.routeStart End:self.mapView.routeEnd];
    }
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
    [self.mapView setRouteResult:rs];
    [self customRouteSymbols];
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
