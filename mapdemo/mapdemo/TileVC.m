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
	NSArray *tileInfos = [TYTiledManager tileInfoByServer:@"http://files.brtbeacon.com" buildingId:@"00210018" toPath:nil];
	if (tileInfos.count) {
		_tileLayer = [[TYTiledLayer alloc] initWithTileRoot:dir withTileInfo:[TYTiledManager findTileInfo:tileInfos byMapID:@"00210018F01"]];
		if(_tileLayer&&!_tileLayer.error)
			[mapView insertMapLayer:_tileLayer atIndex:0];
		else
			NSLog(@"瓦片加载失败：%@",_tileLayer.error);
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
