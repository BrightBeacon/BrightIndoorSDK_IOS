//
//  RouteForbiddenVC.m
//  mapdemo
//
//  Created by thomasho on 2017/10/25.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteForbiddenVC.h"
#import <TYMapSDK/FacilityCategoryEntity.h>

@interface RouteForbiddenVC ()

@end

@implementation RouteForbiddenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"设置禁行" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(forbidButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self initSymbols];
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
}

- (IBAction)forbidButtonClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    //移除所有禁行设施点
    [self.mapView.routeManager removeForbiddenPoints];
    NSString *categoryID = @"150014";
    if (sender.isSelected) {
        [sender setTitle:@"扶梯禁行" forState:UIControlStateNormal];
    }else {
        categoryID = @"150013";
        [sender setTitle:@"电梯禁行" forState:UIControlStateNormal];
    }
    TYSearchAdapter *search = [[TYSearchAdapter alloc] initWithBuildingID:self.mapView.building.buildingID];
    NSArray *array = [search queryPoiByCategoryID:categoryID];
    for (PoiEntity *pe in array) {
        if (pe.poiLayer.integerValue == POI_FACILITY) {
            //添加禁行设施点
            AGSPoint *pt = [AGSPoint pointWithX:pe.labelX.doubleValue y:pe.labelY.doubleValue spatialReference:self.mapView.spatialReference];
            if([self.mapView.routeManager addForbiddenPoint:[TYLocalPoint pointWithX:pt.x Y:pt.y Floor:pe.floorNumber.intValue]] == FALSE){
                NSLog(@"%@ 禁行失败",pe.name);
            }
        }
    }
}

- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
    TYLocalPoint *lp = [TYLocalPoint pointWithX:mappoint.x Y:mappoint.y Floor:mapView.currentMapInfo.floorNumber];
    if (!mapView.routeStart) {
        [mapView setRouteStart:lp];
        [mapView showRouteStartSymbolOnCurrentFloor:lp];
    }else {
        [mapView setRouteEnd:lp];
        [mapView showRouteEndSymbolOnCurrentFloor:lp];
        [mapView.routeManager requestRouteWithStart:mapView.routeStart End:mapView.routeEnd];
        [mapView setRouteStart:nil];
    }
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
    [mapView showRouteResultOnCurrentFloor];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs {
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    NSLog(@"未找到路线");
}

@end
