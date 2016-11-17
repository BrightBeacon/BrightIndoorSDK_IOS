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
//类别高亮
#import "QuadCurveMenu.h"

#define userID @"ty4e13f85911a44a75"
#define buildingID @"00210018"
#define license @"038cd1d0ZzA3NzJuNTM#YGRkNmAxNTc#5fd4f83c"
#define regionUUID @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
#define rootDir [[NSBundle mainBundle] pathForResource:@"MapResource" ofType:nil]//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface ViewController ()<TYMapViewDelegate,TYOfflineRouteManagerDelegate,AGSCalloutDelegate,TYLocationManagerDelegate,UISearchBarDelegate,QuadCurveMenuDelegate,QuadCurveMenuItemDelegate,UIActionSheetDelegate>{
    BOOL isRouting;
    BOOL isFirstlocation;
    
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
@property(nonatomic,strong) TYLocalPoint *currentLocalPoint;

@property (nonatomic,strong) QuadCurveMenu *QCMenu;
@property (nonatomic,strong) IBOutlet UIButton *floorButton;

// 路径管理器
@property (nonatomic,strong) TYOfflineRouteManager *cppOfflineRouteManager;
//定位管理器
@property (nonatomic,strong) TYLocationManager *loc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstlocation = YES;
    [self loadMapView];
    [self QCMenu];
}
#pragma mark - QuadCurveMenu

- (QuadCurveMenu*)QCMenu {
    if (!_QCMenu) {
        NSMutableArray *menus = [NSMutableArray array];
        for (NSString *type in @[@"icon_atm_normal",@"icon_womens_room_normal",@"icon_mens_room_normal",@"icon_childroom_normal",@"icon_staircase_normal",@"icon_stair_normal",@"icon_lift_normal",@"icon_exit_normal"]) {
            QuadCurveMenuItem *menuItem = [[QuadCurveMenuItem alloc] initWithImage:[UIImage imageNamed:type]
                                                                  highlightedImage:[UIImage imageNamed:type]
                                                                      ContentImage:nil
                                                           highlightedContentImage:nil];
            [menus addObject:menuItem];
        }
        _QCMenu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];
        _QCMenu.delegate = self;
        [self.view addSubview:_QCMenu];
    }
    return _QCMenu;
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSArray *cids = @[@"25020",@"160013",@"160012",@"25025",@"150014",@"150012",@"150013",@"150001"];
    [self.mapView showFacilityOnCurrentWithCategory:[[cids objectAtIndex:idx] intValue]];
}

#pragma mark - loadMapView

- (void)loadMapView {
    //拷贝内置地图数据
    if (![[NSFileManager defaultManager] fileExistsAtPath:[rootDir stringByAppendingPathComponent:[buildingID substringToIndex:4]]]) {
        return;
    }
    //设置地图路径
    [TYMapEnvironment setRootDirectoryForMapFiles:rootDir];
    [TYMapEnvironment initMapEnvironment];
    //初始化地图数据
    self.currentCity = [TYCityManager parseCity:[buildingID substringToIndex:4]];
    self.currentBuilding = [TYBuildingManager parseBuilding:buildingID InCity:self.currentCity];
    self.allMapInfos = [TYMapInfo parseAllMapInfo:self.currentBuilding];
    self.currentMapInfo = self.allMapInfos.firstObject;
    [self.mapView initMapViewWithBuilding:self.currentBuilding UserID:userID License:license];
    self.mapView.mapDelegate = self;
    [self.mapView setFloorWithInfo:_currentMapInfo];
    //初始化地图标识
    [self initSymbols];
    
    //点击地图出现小圆点图层
    hintLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:hintLayer];
    
    
    //设置地图导航旋转模式
    [self.mapView setMapMode:TYMapViewModeDefault];
    //设置地图选中高亮（本例已在TYMapView:PoiSelected回调中高亮Poi）
    //    [self.mapView setHighlightPOIOnSelection:YES];
    //设置地图弹窗
    self.mapView.callout.delegate = self;
}

- (void)TYMapViewDidLoad:(TYMapView *)mapView {
    //路径规划初始化
    _cppOfflineRouteManager = [TYOfflineRouteManager routeManagerWithBuilding:self.currentBuilding MapInfos:self.allMapInfos];
    _cppOfflineRouteManager.delegate = self;
    
    //定位初始化
    [TYBLEEnvironment setRootDirectoryForFiles:rootDir];
    _loc = [[TYLocationManager alloc] initWithBuilding:self.currentBuilding];
    [_loc setRssiThreshold:-100];
    [_loc setBeaconRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:regionUUID] identifier:@"identifier"]];
    [_loc startUpdateLocation];
    _loc.delegate = self;
}
#pragma mark - **************** 定位回调
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation{
    [self.mapView showLocation:newLocation];
    if (isFirstlocation) {
        isFirstlocation = NO;
        AGSPoint *pt = [AGSPoint pointWithX:newLocation.x y:newLocation.y spatialReference:self.mapView.spatialReference];
        [self.mapView centerAtPoint:pt animated:YES];
    }
    self.startLocalPoint = newLocation;
    self.currentLocalPoint = newLocation;
    
    
    // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
    if (self.mapView.currentMapInfo.floorNumber!=newLocation.floor) {
        TYMapInfo *targetMapInfo = nil;
        for (targetMapInfo in self.allMapInfos) {
            if (targetMapInfo.floorNumber == newLocation.floor) {
                [self.mapView setFloorWithInfo:targetMapInfo];
                break;
            }
        }
    }
    if (isRouting) {
        // 在地图显示当前楼层导航
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:newLocation];
        BOOL isDeciatig = [routeResult isDeviatingFromRoute:newLocation WithThrehold:5.0];
        if (isDeciatig) {
            //重置导航层，移除显示的结果，并将导航结果清空
            [self.mapView resetRouteLayer];
            [self requestRoute];
        }
    }
}
- (void)TYLocationManagerdidFailUpdateLocation:(TYLocationManager *)manager{
    
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedBeacons:(NSArray *)beacons{
    
}
- (void)TYLocationManager:(TYLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons{
    for (TYBeacon *b in beacons) {
        NSLog(@"%@_%d",b.minor,b.rssi);
    }
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
        [self.mapView zoomToGeometry:currentRoutePart.route.envelope withPadding:80 animated:YES];
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
- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array {
    TYPoi *poi = array.firstObject;
    if (poi) {
        [mapView highlightPoi:poi];
        //        AGSPoint *location = nil;
        //        if ([poi.geometry isKindOfClass:[AGSPolygon class]]) {
        //            location = [[AGSGeometryEngine defaultGeometryEngine] labelPointForPolygon:(AGSPolygon *)poi.geometry];
        //        }else{
        //            location = (AGSPoint *)poi.geometry;
        //        }
        //        mapView.callout.delegate = self;
        //        mapView.callout.title = poi.name;
        //        mapView.callout.detail = poi.poiID;
        //        [mapView.callout showCalloutAt:location screenOffset:CGPointZero animated:YES];
    }
}
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint
{
    [self.view endEditing:YES];
    //显示当前点击位置(AGSGraphicsLayer *)mapView.baseLayer
    if ([mapView.baseLayer.fullEnvelope containsPoint:mappoint]) {
        [hintLayer removeAllGraphics];
        [hintLayer addGraphic:[AGSGraphic graphicWithGeometry:mappoint symbol:markerSymbol attributes:nil]];
    }
    
    //弹窗提示（配置了delegate会自动弹窗）
    //[self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - **************** 配置默认弹出样式（可以自定义customView）

- (BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint{
    callout.image = [UIImage imageNamed:@"GreenPushpin"];
    callout.detail = self.startLocalPoint?@"终点":@"起点";
    id title = [feature attributeForKey:@"NAME"];
    callout.title = [title isEqual:[NSNull null]]?@"未命名":title;
    callout.titleColor = [UIColor blackColor];
    callout.detailColor = [UIColor blackColor];
    return YES;
}
- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    if (self.startLocalPoint) {
        self.endLocalPoint = [TYLocalPoint pointWithX:callout.mapLocation.x Y:callout.mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];
    }else{
        self.startLocalPoint = [TYLocalPoint pointWithX:callout.mapLocation.x Y:callout.mapLocation.y Floor:self.mapView.currentMapInfo.floorNumber];;
    }
    [callout dismiss];
    [self requestRoute];
}

#pragma mark - **************** methods

//路径规划测试。请自行引入数据库工具读取POD.db数据库，下面使用了FMDatabase库
//- (void)test
//{
//    NSString *poiDBPath = [[TYMapEnvironment getBuildingDirectory:self.currentBuilding] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_POI.db", self.currentBuilding.buildingID]];
//    FMDatabase *db = [FMDatabase databaseWithPath:poiDBPath];
//    [db open];
//    
//    NSString *sql = @"select * from poi";
//    FMResultSet *rs = [db executeQuery:sql];
//    while ([rs next]) {
//        NSString *poiID = [rs stringForColumn:@"POI_ID"];
//        if ([poiID isEqualToString:@"00210018F0110001"]) {
//            double x = [rs doubleForColumn:@"LABEL_X"];
//            double y = [rs doubleForColumn:@"LABEL_Y"];
//            int floor = [rs intForColumn:@"FLOOR_INDEX"];
//            self.startLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
//        }
//        
//        if ([poiID isEqualToString:@"00210018F0110005"]) {
//            double x = [rs doubleForColumn:@"LABEL_X"];
//            double y = [rs doubleForColumn:@"LABEL_Y"];
//            int floor = [rs intForColumn:@"FLOOR_INDEX"];
//            self.endLocalPoint = [TYLocalPoint pointWithX:x Y:y Floor:floor];
//        }
//    }
//    [db close];
//    [self requestRoute];
//}

- (void)requestRoute
{
    if (self.startLocalPoint == nil || self.endLocalPoint == nil) {
        return;
    }
    routeResult = nil;
    isRouting = YES;
    
    [_cppOfflineRouteManager requestRouteWithStart:self.startLocalPoint End:self.endLocalPoint];
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
#pragma mark - Actions

- (IBAction)floorButtonClicked:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择楼层" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (TYMapInfo *mapInfo in self.allMapInfos) {
        [sheet addButtonWithTitle:mapInfo.floorName];
    }
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex<self.allMapInfos.count) {
        self.currentMapInfo = [self.allMapInfos objectAtIndex:buttonIndex];
        [self.mapView setFloorWithInfo:self.currentMapInfo];
    }
}
- (IBAction)zoomOutButtonClicked:(id)sender {
    [self.mapView zoomOut:YES];
    NSLog(@"%f",
          [self.mapView mapScale]);
}
- (IBAction)zoomInClicked:(id)sender {
    [self.mapView zoomIn:YES];
    NSLog(@"%f",
          [self.mapView mapScale]);
}
- (IBAction)locButtonClicked:(id)sender {
    [_loc startUpdateLocation];
    if(self.currentLocalPoint)[self.mapView zoomToResolution:0.1 withCenterPoint:[AGSPoint pointWithX:self.currentLocalPoint.x y:self.currentLocalPoint.y spatialReference:self.mapView.spatialReference] animated:YES];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [_loc stopUpdateLocation];
    self.currentLocalPoint = nil;
    [self.mapView removeLocation];
    
    [self.mapView resetRouteLayer];
    self.startLocalPoint = nil;
    self.endLocalPoint = nil;
    [self.view endEditing:YES];
}

#pragma mark - SearchDelgate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        //to do
        
        TYPoi *poi = [self.mapView getPoiOnCurrentFloorWithPoiID:searchBar.text layer:POI_ROOM];
        if (poi&&poi.categoryID!=800&&poi.categoryID!=300) {
            [self.mapView highlightPoi:poi];
        }
    }
}
@end
