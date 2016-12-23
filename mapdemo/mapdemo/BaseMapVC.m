//
//  BaseMapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "BaseMapVC.h"
#import "MapDataSync.h"

@interface BaseMapVC ()

@property (nonatomic,strong) TYBuilding *currentBuilding;

@end

@implementation BaseMapVC

- (void)viewDidLoad {
	[super viewDidLoad];
	//登录http://developer.brtbeacon.com，查看我的建筑列表，获取参数

	//设置地图路径、下载文件路径
	[self setMapEnvironment:kBuildingId];
	//从路径加载地图
	[self initMap];
	//从服务器检查更新
	[self updateMap];
}

- (void)dealloc {
	NSLog(@"check if '%@' recycled",NSStringFromClass(self.class));
}

//设置下载地图文件目录
- (void)setMapEnvironment:(NSString *)buidingId{
	NSString *dir = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",buidingId];
	[TYMapEnvironment initMapEnvironment];
	[TYMapEnvironment setRootDirectoryForMapFiles:dir];
	if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
		//withIntermediateDirectories 是否覆盖
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
		[self copyFilesIfNeed];
	}
}

- (void)copyFilesIfNeed {
	NSString *sourceRootDir = [[NSBundle mainBundle] pathForResource:kBuildingId ofType:nil];
	if (sourceRootDir == nil) {
		return;
	}
	NSString *targetRootDir = [TYMapEnvironment getRootDirectoryForMapFiles];

	NSLog(@"source path:\n%@  target path:\n%@",sourceRootDir,targetRootDir);

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator;
	enumerator = [fileManager enumeratorAtPath:sourceRootDir];
	NSString *name;
	while (name= [enumerator nextObject]) {
		NSString *sourcePath = [sourceRootDir stringByAppendingPathComponent:name];
		NSString *targetPath = [targetRootDir stringByAppendingPathComponent:name];
		NSString *pathExtension = sourcePath.pathExtension;

		if (pathExtension.length > 0) {
			[fileManager copyItemAtPath:sourcePath toPath:targetPath error:nil];
		} else {
			[fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
}
//解析地图数据、加载网络地图(若手动删除本地文件，请注意清空版本号)
- (void)updateMap {
	//示例网络加载地图,可自实现,注意plist添加http例外信息
		NSString *url = [NSString stringWithFormat:url_mapnew,kBuildingId,kAppKey,kLicense];
		[MapDataSync updateMapData:url onCompletion:^(NSError *err) {
			if (err) {
				NSLog(@"无更新地图数据%@",err);
			}else{
				[self initMap];
			}
		}];
}


//处理地图License
- (NSString *)trimLicense:(NSString *)license {
	return [[license stringByReplacingOccurrencesOfString:@"brtd_" withString:@"#"] stringByReplacingOccurrencesOfString:@"brtx_" withString:@":"];
}

- (void)initMap {
	TYCity *city = [TYCityManager parseCity:[kBuildingId substringToIndex:4]];
	_currentBuilding = [TYBuildingManager parseBuilding:kBuildingId InCity:city];
	if (_currentBuilding) {
		_allMapInfo = [TYMapInfo parseAllMapInfo:self.currentBuilding];
		if (self.mapView.loaded) {
			[self.mapView switchBuilding:_currentBuilding UserID:kAppKey License:[self trimLicense:kLicense]];
		}else{
			[self.mapView initMapViewWithBuilding:self.currentBuilding UserID:kAppKey License:[self trimLicense:kLicense]];
			self.mapView.backgroundColor = [UIColor whiteColor];
			self.mapView.mapDelegate = self;
			self.mapView.highlightPOIOnSelection = NO;
			self.mapView.allowRotationByPinching = YES;
		}
		[self.mapView setFloorWithInfo:_allMapInfo.firstObject];
	}
}
#pragma mark - **************** 常用控件
- (void)showFloorControl
{
	if (_allMapInfo.count<=1) {
		return;
	}
	NSMutableArray *floorNameArray = [[NSMutableArray alloc] init];
	for (TYMapInfo *mapInfo in _allMapInfo) {
		[floorNameArray addObject:mapInfo.floorName];
	}
	UISegmentedControl *_floorSegment = [[UISegmentedControl alloc] initWithItems:floorNameArray];
	_floorSegment.frame = CGRectMake(20, 80, self.view.frame.size.width - 20 * 2, 30);
	_floorSegment.tintColor = [UIColor blueColor];
	_floorSegment.selectedSegmentIndex = 0;
	[_floorSegment addTarget:self action:@selector(floorChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_floorSegment];
}
//地图按2倍率缩放
- (void)showZoomControl {
	CGRect frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 160, 40, 40);
	UIButton *zin = [[UIButton alloc] initWithFrame:frame];
	[zin setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
	[zin addTarget:self.mapView action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zin];


	frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 120, 40, 40);
	UIButton *zout = [[UIButton alloc] initWithFrame:frame];
	[zout setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
	[zout addTarget:self.mapView action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zout];
}

//切换楼层
- (IBAction)floorChanged:(UISegmentedControl *)sender {
	[self.mapView setFloorWithInfo:[self.allMapInfo objectAtIndex:sender.selectedSegmentIndex]];
}

#pragma mark - **************** 地图回调
//加载第一层layer成功
- (void)TYMapViewDidLoad:(TYMapView *)mapView {
	NSLog(@"%@",NSStringFromSelector(_cmd));
}

//地图楼层切换
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
	NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
//	TYPoi *poi = array.firstObject;
//	if (![poi isEqual:[NSNull null]]) {
//		[mapView highlightPoi:poi];
//	}
}

//地图点击
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint {
//	TYPoi *poi = [mapView extractRoomPoiOnCurrentFloorWithX:mappoint.x Y:mappoint.y];
//	if (![poi isEqual:[NSNull null]]) {
//		[mapView highlightPoi:poi];
//	}
}

#pragma mark - **************** 路径规划

- (TYOfflineRouteManager *)routeManager {
	if (!_routeManager) {
		_routeManager = [TYOfflineRouteManager routeManagerWithBuilding:self.mapView.building MapInfos:self.allMapInfo];
		_routeManager.delegate = self;
	}
	return _routeManager;
}

//路径规划失败
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
}
//路径规划成功
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
}

#pragma mark - **************** 默认弹窗
- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
	return YES;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout{

}
@end
