//
//  ViewController.m
//  mapdemo
//
//  Created by thomasho on 16/5/20.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "ViewController.h"
#import <TYMapSDK/TYMapSDK.h>
#import <TYLocationEngine/TYLocationEngine.h>

@interface ViewController ()<TYMapViewDelegate,TYOfflineRouteManagerDelegate,AGSCalloutDelegate,TYLocationManagerDelegate>{
    // 路径管理器
    TYOfflineRouteManager *cppOfflineRouteManager;
    
    
    BOOL isRouting;
    
    // 路径规划结果
    TYRouteResult *routeResult;
    TYRoutePart *currentRoutePart;
    NSArray *routeGuides;
    
    AGSGraphicsLayer *hintLayer;
    
    // 起点、终点、切换点标识符号
    AGSPictureMarkerSymbol *startSymbol;
    AGSPictureMarkerSymbol *endSymbol;
    AGSPictureMarkerSymbol *switchSymbol;
    AGSSimpleMarkerSymbol *markerSymbol;
    AGSPictureMarkerSymbol *locationSymbol;
}
@property (weak, nonatomic) IBOutlet TYMapView *mapView;
@property (strong, nonatomic) TYMapInfo *currentMapInfo;
@property (strong, nonatomic) TYCity *currentCity;
@property (strong, nonatomic) TYBuilding *currentBuilding;
@property (strong, nonatomic) NSArray *allMapInfos;

@property(nonatomic,strong) TYLocalPoint *startLocalPoint;
@property(nonatomic,strong) TYLocalPoint *endLocalPoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化地图数据
    self.currentCity = [TYCityManager parseCity:@"0021"];
    self.currentBuilding = [TYBuildingManager parseBuilding:@"00210018" InCity:self.currentCity];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    TYMapInfo *mapInfo = self.allMapInfos.firstObject;
    [self.mapView initMapViewWithBuilding:self.currentBuilding UserID:@"ty4e13f85911a44a75" License:@"038cd1d0ZzA3NzJuNTM#YGRkNmAxNTc#5fd4f83c"];
    self.mapView.mapDelegate = self;
    [self.mapView setFloorWithInfo:mapInfo];
    
    //初始化地图标识
    [self initSymbols];
    
    //点击地图出现小圆点图层
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    //路径规划初始化
    cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    
    //定位初始化
    TYLocationManager *loc = [[TYLocationManager alloc] initWithBuilding:self.currentBuilding];
    [loc setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"] identifier:@"testforloc"]];
    [loc startUpdateLocation];
    loc.delegate = self;
    
    //设置地图导航旋转模式
    [self.mapView setMapMode:TYMapViewModeDefault];
}
#pragma mark - **************** 定位回调
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation{
    [self.mapView showLocation:newLocation];
    self.endLocalPoint = newLocation;
    
}
- (void)TYLocationManagerdidFailUpdateLocation:(TYLocationManager *)manager{
    
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedBeacons:(NSArray *)beacons{
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons{
    
}
- (void)updateDeviceHeading:(double)heading initAngle:(int)angle mapViewMode:(int)mode {
    NSLog(@"%f_%d_%d",heading,angle,mode);
}
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateDeviceHeading:(double)newHeading {
    //处理地图旋转，依据设置的旋转模式
    [self.mapView processDeviceRotation:newHeading];
}
#pragma mark - **************** 路径规划
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    //移除其他图层显示
    [hintLayer removeAllGraphics];
    
    routeResult = rs;
    
    [self.mapView setRouteResult:rs];
    [self.mapView setRouteStart:self.startLocalPoint];
    [self.mapView setRouteEnd:self.endLocalPoint];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray *routePartArray = [routeResult getRoutePartsOnFloor:self.currentMapInfo.floorNumber];
    if (routePartArray && routePartArray.count > 0) {
        currentRoutePart = [routePartArray objectAtIndex:0];
    }
    
    if (currentRoutePart) {
        routeGuides = [routeResult getRouteDirectionalHint:currentRoutePart];
    }
    //    [self.mapView setMapMode:TYMapViewModeFollowing];
}

#pragma mark - **************** 地图回调

- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}

- (void)TYMapViewDidZoomed:(TYMapView *)mapView
{
    if (isRouting) {
        [self.mapView showRouteResultOnCurrentFloor];
    }
}


- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    NSLog(@"(%f, %f) in floor %d", mappoint.x, mappoint.y, self.currentMapInfo.floorNumber);
    
    //显示当前点击位置
    [hintLayer removeAllGraphics];
    [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    
    //弹窗提示
    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - **************** 配置默认弹出样式（建议自定义customView）
- (BOOL)TYMapView:(TYMapView *)mapView willShowForGraphic:(AGSGraphic *)graphic layer:(AGSGraphicsLayer *)layer mapPoint:(AGSPoint *)mappoint{
    self.mapView.callout.delegate = self;
    return [self callout:mapView.callout willShowForFeature:graphic layer:layer mapPoint:mappoint];
}

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
    callout.image = [UIImage imageNamed:@"GreenPushpin"];
    callout.title = _endLocalPoint?@"终点":@"设置起点";
    callout.detail = _endLocalPoint?@"点击开始导航":@"点击设置起点";
    callout.titleColor = [UIColor blackColor];
    callout.detailColor = [UIColor blackColor];
    return YES;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    self.startLocalPoint = _endLocalPoint;
    self.endLocalPoint = [TYLocalPoint pointWithX:callout.mapLocation.x Y:callout.mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];
    [callout dismiss];
    [self requestRoute];
}

#pragma mark - **************** methods

/*路径规划测试。请自行引入数据库工具读取POD.db数据库，下面使用了FMDatabase库
 - (void)test
 {
 NSString *poiDBPath = [[TYMapEnvironment getBuildingDirectory:self.currentBuilding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_POI.db", self.currentBuilding.buildingID]];
 FMDatabase *db = [FMDatabase databaseWithPath:poiDBPath];
 [db open];
 
 NSString *sql = @"select * from poi";
 FMResultSet *rs = [db executeQuery:sql];
 while ([rs next]) {
 NSString *poiID = [rs stringForColumn:@"POI_ID"];
 if ([poiID isEqualToString:@"00210018F0110001"]) {
 double x = [rs doubleForColumn:@"LABEL_X"];
 double y = [rs doubleForColumn:@"LABEL_Y"];
 int floor = [rs intForColumn:@"FLOOR_INDEX"];
 self.startLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
 }
 
 if ([poiID isEqualToString:@"00210018F0110005"]) {
 double x = [rs doubleForColumn:@"LABEL_X"];
 double y = [rs doubleForColumn:@"LABEL_Y"];
 int floor = [rs intForColumn:@"FLOOR_INDEX"];
 self.endLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
 }
 }
 [db close];
 [self requestRoute];
 }*/

- (void)requestRoute
{
    if (self.startLocalPoint == nil || self.endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    
    [cppOfflineRouteManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
}

- (void)initSymbols
{
    startSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"start"];
    startSymbol.offset = CGPointMake(0, 22);
    
    endSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"end"];
    endSymbol.offset = CGPointMake(0, 22);
    
    switchSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"nav_exit"];
    
    markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor greenColor]];
    markerSymbol.size = CGSizeMake(5, 5);
    
    [self.mapView setRouteStartSymbol:startSymbol];
    [self.mapView setRouteEndSymbol:endSymbol];
    [self.mapView setRouteSwitchSymbol:switchSymbol];
    
    
    AGSPictureMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
}
@end
