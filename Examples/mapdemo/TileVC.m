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
    tileManager = [[TYTiledManager alloc] initWithBuilding:@"00210105"];
    TYMapView *mapView = [[TYMapView alloc] initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mapView];
    
    mapView.allowRotationByPinching  = YES;
    mapView.touchDelegate = self;
    //测试；实际请加载到对应矢量地图楼层加载处
    [self TYMapView:mapView didFinishLoadingFloor:@"-1"];
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(NSString *)floorName {

    TYTiledLayer *tileLayer = (TYTiledLayer *)[mapView mapLayerForName:@"layerid"];
    [mapView removeMapLayer:tileLayer];

    NSString *dir = [TYMapEnvironment getRootDirectoryForMapFiles];
    tileLayer = [[TYTiledLayer alloc] initWithTileRoot:dir withTileInfo:[tileManager tileInfoByFloor:floorName]];
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
