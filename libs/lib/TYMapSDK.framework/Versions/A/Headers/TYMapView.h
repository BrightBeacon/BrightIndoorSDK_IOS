//
//  TYMapView.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYMapInfo.h"
#import "TYPoi.h"
#import "TYRenderingScheme.h"
#import "TYRouteResult.h"
#import "TYDirectionalHint.h"
#import <TYMapData/TYMapData.h>

/**
    地图模式类型：默认模式和跟随模式
 */
typedef enum {
    TYMapViewModeDefault = 0,
    TYMapViewModeFollowing = 1
} TYMapViewMode;

@class TYMapView;

/**
 *  地图代理协议
 */
@protocol TYMapViewDelegate <NSObject>

@optional
/**
 *  地图点选事件回调方法
 *
 *  @param mapView  地图视图
 *  @param screen   点击事件的屏幕坐标
 *  @param mappoint 点击事件的地图坐标
 */
- (void)TYMapView:(TYMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint;

/**
 *  地图POI选中事件回调
 *
 *  @param mapView 地图视图
 *  @param array   选中的POI数组:[TYPoi]
 */
- (void)TYMapView:(TYMapView *)mapView PoiSelected:(NSArray *)array;


/**
 *  地图楼层加载完成回调
 *
 *  @param mapView 地图视图
 *  @param mapInfo 加载楼层信息
 */
- (void)TYMapView:(TYMapView *)mapView didFinishLoadingFloor:(TYMapInfo *)mapInfo;

/**
 *  地图放缩事件回调
 *
 *  @param mapView 地图视图
 */
- (void)TYMapViewDidZoomed:(TYMapView *)mapView;

/**
 *  地图加载完成事件回调
 *
 *  @param mapView 地图视图
 */
- (void)TYMapViewDidLoad:(TYMapView *)mapView;

/**
 *  地图弹出框解除完成事件回调
 *
 *  @param mapView 地图视图
 *  @param callout 地图弹出框
 */
- (void)TYMapView:(TYMapView *)mapView calloutDidDismiss:(AGSCallout *)callout;

/**
 *  地图弹出框即将解除事件回调
 *
 *  @param mapView 地图视图
 *  @param callout 地图弹出框
 */
- (void)TYMapView:(TYMapView *)mapView calloutWillDismiss:(AGSCallout *)callout;

/**
 *  地图即将为要素显示弹出框事件回调
 *
 *  @param mapView  地图视图
 *  @param graphic  目标要素
 *  @param layer    目标要素所在层
 *  @param mappoint 目标点
 *
 *  @return 是否显示弹出框
 */
- (BOOL)TYMapView:(TYMapView *)mapView willShowForGraphic:(AGSGraphic *)graphic layer:(AGSGraphicsLayer *)layer mapPoint:(AGSPoint *)mappoint;

@end

/**
 *  地图视图类
 */
@interface TYMapView : AGSMapView

/**
 *  地图代理，用于处理地图点击、Poi点选事件、弹出框等
 */
@property (nonatomic, weak) id<TYMapViewDelegate> mapDelegate;

/**
 *  当前显示的建筑ID
 */
@property (nonatomic, strong) TYBuilding *building;

/**
 *  当前建筑的当前楼层信息
 */
@property (nonatomic, readonly) TYMapInfo *currentMapInfo;

//@property (nonatomic, readonly) TYParkingLayer *parkingLayer;
//- (NSArray *)getParkingSpacesOnCurrentFloor;

/**
 *  在POI被点选时是否高亮显示，默认为NO
 */
@property (nonatomic, assign) BOOL highlightPOIOnSelection;

/**
 *  重新加载地图
 */
- (void)reloadMapView;


/**
 *  切换楼层方法
 *
 *  @param info 目标楼层的地图信息
 */
- (void)setFloorWithInfo:(TYMapInfo *)info;

/**
 *  设置定位点符号，用于标识定位结果
 *
 *  @param symbol 定位点符号
 */
- (void)setLocationSymbol:(AGSMarkerSymbol *)symbol;

/**
 *  在地图上显示定位结果
 *
 *  @param location 定位结果坐标点
 */
- (void)showLocation:(TYLocalPoint *)location;

/**
 *  在地图上移除定位结果
 */
- (void)removeLocation;

/**
 *  处理设备旋转事件
 *
 *  @param newHeading 设备方向角
 */
- (void)processDeviceRotation:(double)newHeading;

/**
 *  设置地图模式
 *
 *  @param mode 目标地图模式，包括默认模式和跟随模式
 */
- (void)setMapMode:(TYMapViewMode)mode;

/**
 *  设置导航线的起点符号
 *
 *  @param symbol 起点标识符号
 */
- (void)setRouteStartSymbol:(AGSPictureMarkerSymbol *)symbol;

/**
 *  设置导航线的终点符号
 *
 *  @param symbol 终点标识符号
 */
- (void)setRouteEndSymbol:(AGSPictureMarkerSymbol *)symbol;

/**
 *  设置跨层导航切换点符号
 *
 *  @param symbol 切换点标识符号
 */
- (void)setRouteSwitchSymbol:(AGSPictureMarkerSymbol *)symbol;

/**
 *  设置导航结果
 *
 *  @param result 导航结果
 */
- (void)setRouteResult:(TYRouteResult *)result;

/**
 *  设置导航起点
 *
 *  @param start 导航起点
 */
- (void)setRouteStart:(TYLocalPoint *)start;

/**
 *  设置导航终点
 *
 *  @param end 导航终点
 */
- (void)setRouteEnd:(TYLocalPoint *)end;

/**
 *  重置导航层，移除显示的结果，并将导航结果清空
 */
- (void)resetRouteLayer;

/**
 *  清除导航层，只在地图上移除相关显示的结果
 */
- (void)clearRouteLayer;

/**
 *  在地图当前楼层显示起点符号
 *
 *  @param sp 起点位置
 */
- (void)showRouteStartSymbolOnCurrentFloor:(TYLocalPoint *)sp;

/**
 *  在地图当前楼层显示终点符号
 *
 *  @param ep 终点位置
 */
- (void)showRouteEndSymbolOnCurrentFloor:(TYLocalPoint *)ep;

/**
 *  在地图当前楼层显示切换点符号
 *
 *  @param sp 切换点位置
 */
- (void)showRouteSwitchSymbolOnCurrentFloor:(TYLocalPoint *)sp;

/**
 *  在地图显示当前楼层的导航路径
 */
- (void)showRouteResultOnCurrentFloor;


/**
 *  在地图上显示当前楼层目标位置已经过的路径和未经过的剩余路径
 *
 *  @param lp 目标位置
 */
- (void)showPassedAndRemainingRouteResultOnCurrentFloor:(TYLocalPoint *)lp;


/**
 *  在地图显示当前楼层当前位置的剩余路径，结合定位结果，移除已经经过的路径部分
 *
 *  @param lp 当前位置
 */
- (void)showRemainingRouteResultOnCurrentFloor:(TYLocalPoint *)lp;

/**
 *  显示导航提示对应的路径段
 *
 *  @param ds         目标路径提示
 *  @param isCentered 是否移动地图将路径提示段居中
 */
- (void)showRouteHintForDirectionHint:(TYDirectionalHint *)ds Centered:(BOOL)isCentered;

- (void)initMapView;
- (void)loadBuilding:(TYBuilding *)b UserID:(NSString *)uID License:(NSString *)license;

/**
 *  地图初始化方法
 *
 *  @param b       地图显示的目标建筑
 *  @param uID     SDK的用户ID
 *  @param license 目标建筑的License
 */
- (void)initMapViewWithBuilding:(TYBuilding *)b UserID:(NSString *)uID License:(NSString *)license;

/**
 *  切换建筑方法，将地图切换到目标建筑
 *
 *  @param b       切换的目标建筑
 *  @param uID     SDK的用户ID
 *  @param license 目标建筑的License
 */
- (void)switchBuilding:(TYBuilding *)b UserID:(NSString *)uID License:(NSString *)license;

/**
 *  移动地图将特定坐标限定在特定屏幕范围内
 *
 *  @param location 目标点地图坐标
 *  @param range 目标屏幕范围
 *
 */
- (void)restrictLocation:(AGSPoint *)location toScreenRange:(CGRect)range;

/**
 *  清除高亮显示的POI
 */
- (void)clearSelection;

/**
 *  返回当前楼层的所有公共设施类型
 *
 *  @return 公共设施类型数组:[NSNumber]
 */
- (NSArray *)getAllFacilityCategoryIDOnCurrentFloor;

/**
 *  显示当前楼层的所有公共设施
 */
- (void)showAllFacilitiesOnCurrentFloor;

/**
 *  显示当前楼层的特定类型公共设施
 *
 *  @param categoryID 公共设施类型ID
 */
- (void)showFacilityOnCurrentWithCategory:(int)categoryID;

/**
 *  显示当前楼层的特定类型公共设施
 *
 *  @param categoryIDs 公共设施类型ID数组
 */
- (void)showFacilityOnCurrentWithCategorys:(NSArray *)categoryIDs;

/**
 *  获取当前楼层下特定子层特定poiID的信息
 *
 *  @param pid   poiID
 *  @param layer 目标子层
 *
 *  @return poi信息
 */
- (TYPoi *)getPoiOnCurrentFloorWithPoiID:(NSString *)pid layer:(POI_LAYER)layer;

/**
 *  高亮显示POI
 *
 *  @param poi 目标poi
 *  目标poi至少包含poiID和layer信息，当前支持ROOM和FACILITY高亮
 */
- (void)highlightPoi:(TYPoi *)poi;

/**
 *  高亮显示一组POI
 *
 *  @param poiArray 目标poi数组
 */
- (void)highlightPois:(NSArray *)poiArray;

/**
 *  根据坐标x和y提取当前楼层的ROOM POI
 *
 *  @param x 坐标x
 *  @param y 坐标y
 *
 *  @return ROOM POI
 */
- (TYPoi *)extractRoomPoiOnCurrentFloorWithX:(double)x Y:(double)y;

/**
 *  设置是否启用路线修正功能，需要添加额外的路线数据
 *
 *  @param enabled 是否启用
 */
- (void)setPathCalibrationEnabled:(BOOL)enabled;

/**
 *  设置路线修正的缓冲宽度
 *
 *  @param bufferWidth 缓冲宽度
 */
- (void)setPathCalibrationBuffer:(double)bufferWidth;

/**
 *  获取路径修正点。
 *  若目标点落在路径缓冲区之外，则返回目标点。
 *
 *  @param point 目标点
 *
 *  @return 修正点
 */
- (AGSPoint *)getCalibratedPoint:(AGSPoint *)point;

/**
 *  设置被占用车位颜色
 *
 *  @param color 被占用车位颜色
 */
- (void)setOccupiedParkingColor:(UIColor *)color;

/**
 *  设置空车位颜色
 *
 *  @param color 空车位颜色
 */
- (void)setAvailableParkingColor:(UIColor *)color;

/**
 *  显示车位状态
 *
 *  @param occupiedArray  被占用车位poiID数组
 *  @param availableArray 空车位poiID数组
 */
- (void)showOccupiedParkingSpaces:(NSArray *)occupiedArray AvailableParkingSpaces:(NSArray *)availableArray;

/**
 *  隐藏车位状态
 */
- (void)hideParkingSpaces;

/**
 *  设置是否启用标识重叠检测
 *
 *  @param enabled 是否启用
 */
- (void)setLabelOverlapDetectingEnabled:(BOOL)enabled;

/**
 *  当前是否启用标识重叠检测
 *
 *  @return 是否启用
 */
- (BOOL)isLabelOverlapDetectingEnabled;

/**
 *  设置地图的自定义放缩层级，用于按层级显示标签。
 *
 *  @param dict 自定义放缩层级，{Integer: Double} -> {Level : MapScale}
 */
- (void)setScaleLevels:(NSDictionary *)dict;

/**
 *  获取当前地图所处的自定义放缩层级
 *
 *  @return 当前所处的放缩层级
 */
- (int)getCurrentLevel;

@end

