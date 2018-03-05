//
//  TileVC.m
//  mapdemo
//
//  Created by thomasho on 17/1/11.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "TileVC.h"
#import <TYTileMapSDK/TYTileMapSDK.h>
#import <TYMapSDK/TYMapSDK.h>

@interface TileVC ()<AGSMapViewTouchDelegate> {

    TYTiledManager *tileManager;

}
@end
@implementation TileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    tileManager = [[TYTiledManager alloc] initWithBuilding:@"00210025"];
    TYMapView *mapView = [[TYMapView alloc] initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mapView];
    
    mapView.allowRotationByPinching  = YES;
    mapView.touchDelegate = self;
    //测试；实际请加载到对应矢量地图楼层加载处
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self TYMapView:mapView didFinishLoadingFloor:@"F1"];
    });
    
    //设置放大限制：[6米，1000米]/整个view宽
    [mapView setMaxResolution:1000/mapView.frame.size.width];
    [mapView setMinResolution:6/mapView.frame.size.width];
    
    self.title = @"瓦片演示图";
    
    //设置当前显示为：100米
    double betterResolution = 100/mapView.frame.size.width;
    [mapView zoomToResolution:betterResolution animated:YES];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(NSString *)floorName {

    TYTiledLayer *tileLayer = (TYTiledLayer *)[mapView mapLayerForName:@"layerid"];
    [mapView removeMapLayer:tileLayer];

    NSString *dir = [TYMapEnvironment getRootDirectoryForMapFiles];
    tileLayer = [[TYTiledLayer alloc] initWithTileRoot:dir withTileInfo:[tileManager tileInfoByFloor:floorName]];
    //必要时清空缓存瓦片，默认使用本地缓存瓦片
    //[tileLayer removeTileCache];
    if(tileLayer&&!tileLayer.error){
        [mapView insertMapLayer:tileLayer withName:@"layerid" atIndex:0];
        AGSPoint *center = tileLayer.fullEnvelope.center;
        [mapView centerAtPoint:center animated:YES];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"无法加载图层数据" message:[tileLayer.error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }

}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features {
    NSLog(@"%.2f,%.2f",mappoint.x,mappoint.y);
}

@end
