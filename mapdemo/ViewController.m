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
#import "FMDatabase.h"

@interface ViewController ()<TYMapViewDelegate,TYOfflineRouteManagerDelegate>{
    // 路径管理器
    TYOfflineRouteManager *cppOfflineRouteManager;
    
    
    BOOL isRouting;
    
    // 路径规划结果
    TYRouteResult *routeResult;
    TYRoutePart *currentRoutePart;
    NSArray *routeGuides;
    
    AGSGraphicsLayer *hintLayer;
    
    // 起点、终点、切换点标识符号
    AGSSimpleMarkerSymbol *startSymbol;
    AGSSimpleMarkerSymbol *endSymbol;
    AGSSimpleMarkerSymbol *switchSymbol;
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
   
    /*AGSTiledMapServiceLayer*tiledLayer=[AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"]];
    [self.mapView addMapLayer:tiledLayer];
    self.mapView.allowRotationByPinching = YES;
    [self.mapView enableWrapAround];
    [self.mapView.locationDisplay startDataSource];
    //显示中国经纬度范围
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:73 ymin:3 xmax:135 ymax:53 spatialReference:self.mapView.spatialReference];
    [self.mapView zoomToEnvelope:envelope animated:YES];*/
    
    self.currentCity = [TYCityManager parseCity:@"0021"];
    self.currentBuilding = [TYBuildingManager parseBuilding:@"00210018" InCity:self.currentCity];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    TYMapInfo *mapInfo = self.allMapInfos.firstObject;
    [self.mapView initMapViewWithBuilding:self.currentBuilding UserID:@"ty4e13f85911a44a75" License:@"26db2af1g0772n53`dd9`666101ec55a"];
    self.mapView.mapDelegate = self;
    [self.mapView setFloorWithInfo:mapInfo];
    
    [self initSymbols];
    
    //点击出现小圆点图层
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    //路径规划
    cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    cppOfflineRouteManager.delegate = self;
    //    [self test];
    
    //定位
    TYLocationManager *loc = [[TYLocationManager alloc] initWithBuilding:self.currentBuilding];
    [loc setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"] identifier:@"testforloc"]];
    [loc startUpdateLocation];
    loc.delegate = self;
    
    [self.mapView setMapMode:TYMapViewModeDefault];
}
#pragma mark - **************** locationManager
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation{
    [self.mapView showLocation:newLocation];
    self.startLocalPoint = newLocation;
    
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
    [self.mapView processDeviceRotation:newHeading];
    // 将设备的方向角度换算成弧度
    /*CGFloat headings = -1.0f * M_PI * newHeading / 180.0f;
     // 创建不断改变CALayer的transform属性的属性动画
     CABasicAnimation* anim = [CABasicAnimation
     animationWithKeyPath:@"transform"];
     CATransform3D fromValue = self.mapView.layer.transform;
     // 设置动画开始的属性值
     anim.fromValue = [NSValue valueWithCATransform3D: fromValue];
     // 绕Z轴旋转heading弧度的变换矩阵
     CATransform3D toValue = CATransform3DMakeRotation(headings , 0 , 0 , 1);
     // 设置动画结束的属性
     anim.toValue = [NSValue valueWithCATransform3D: toValue];
     anim.duration = 0.5;
     anim.removedOnCompletion = YES;
     // 设置动画结束后znzLayer的变换矩阵
     self.mapView.layer.transform = toValue;
     // 为znzLayer添加动画
     [self.mapView.layer addAnimation:anim forKey:nil];*/
}
#pragma mark - **************** offlineRoute
- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)offlineRouteManager:(TYOfflineRouteManager *)routeManager didSolveRouteWithResult:(TYRouteResult *)rs
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
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

#pragma mark - **************** mapViewDelegate

- (void)TYMapViewDidLoad:(TYMapView *)mapView {
    //测试初始化，起点。
    AGSPoint *point = self.mapView.visibleAreaEnvelope.center;
    self.startLocalPoint = [TYLocalPoint pointWithX:point.x Y:point.y Floor:self.mapView.currentMapInfo.floorNumber];
    //测试放置自定义图片
    AGSGraphicsLayer *poiLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:poiLayer];
    AGSPictureMarkerSymbol *poiSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GreenPushpin"];
    AGSPoint *poiCoord = [AGSPoint pointWithX:self.mapView.visibleAreaEnvelope.center.x y:self.mapView.visibleAreaEnvelope.center.y spatialReference:self.mapView.spatialReference];
    [poiLayer addGraphic:[AGSGraphic graphicWithGeometry:poiCoord symbol:poiSymbol attributes:nil]];
    [poiLayer refresh];
}

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
    
    //弹窗callout
    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - **************** callout

- (BOOL)TYMapView:(TYMapView *)mapView willShowForGraphic:(TYGraphic *)graphic layer:(TYGraphicsLayer *)layer mapPoint:(TYPoint *)mappoint {
    mapView.callout.image = [UIImage imageNamed:@"start"];
    mapView.callout.title = @"导航";
    mapView.callout.detail = @"testForDetail";
    mapView.callout.titleColor = [UIColor blackColor];
    mapView.callout.detailColor = [UIColor blackColor];
    mapView.callout.delegate = self;
    return NO;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    self.endLocalPoint = [TYLocalPoint pointWithX:callout.mapLocation.x Y:callout.mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];
    [callout dismiss];
    [self requestRoute];
}

#pragma mark - **************** methods

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
}

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
    
    
    TYMarkerSymbol *locSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[UIImage imageNamed:@"locationArrow"]];
    [self.mapView setLocationSymbol:locSymbol];
}
@end
