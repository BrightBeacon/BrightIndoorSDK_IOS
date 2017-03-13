//
//  TileVC.m
//  mapdemo
//
//  Created by thomasho on 17/1/11.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "TileVC.h"
#import <TYTileMapSDK/TYTileMapSDK.h>

@interface TileVC ()
@property (nonatomic,strong) TYTiledLayer *tileLayer;
@end

@implementation TileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
}

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo {
	[mapView removeMapLayer:_tileLayer];
	NSString *dir = [TYMapEnvironment getRootDirectoryForMapFiles];
    TYTiledLayer *tileLayer = (TYTiledLayer *)[self.mapView mapLayerForName:mapInfo.buildingID];
    [self.mapView removeMapLayer:tileLayer];

    NSString *tileInfoPath = [dir stringByAppendingPathComponent:@"tileInfo.json"];
    NSArray *tileInfos = [TYTiledManager tileInfoByServer:@"http:/files.brtbeacon.com" buildingId:mapInfo.buildingID toPath:tileInfoPath];
    tileLayer = [[TYTiledLayer alloc] initWithTileRoot:dir withTileInfo:[TYTiledManager findTileInfo:tileInfos byMapID:mapInfo.mapID]];
    if(tileLayer&&!tileLayer.error){
        [self.mapView insertMapLayer:tileLayer withName:mapInfo.buildingID atIndex:0];
        [self.mapView setFloorWithInfo:mapInfo];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"无法加载图层数据" message:[tileLayer.error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
