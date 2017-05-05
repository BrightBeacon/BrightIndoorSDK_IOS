//
//  TYLocationManager.h
//  BLEProject
//
//  Created by innerpeacer on 15/2/11.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <TYMapData/TYMapData.h>
//#import <TYMapSDK/TYMapSDK.h>

//@class TYLocationManager;


@protocol TYLocationManagerDelegate;

@interface TYLocationManager : NSObject

/**
 *  初始化定位引擎
 *
 *  @param buildingID 目标建筑ID
 *  @param aKey 用户appkey
 *
 *  @return 定位引擎实例
 */
- (id)initWithBuilding:(NSString *)buildingID appKey:(NSString *)aKey;

/**
 *  开启定位引擎
 */
- (void)startUpdateLocation;

/**
 *  停止定位引擎
 */
- (void)stopUpdateLocation;

/**
 *  获取最近一次的位置信息
 *
 *  @return 位置信息
 */
- (TYLocalPoint *)getLastLocation;

/**
 *  设置用于定位的Beacon参数
 *
 *  @param region Beacon Region参数
 */
- (void)setBeaconRegion:(CLBeaconRegion *)region;

/**
 *  设置是否限制定位使用的beacon个数
 *
 *  @param lbn 是否限制
 */
- (void)setLimitBeaconNumber:(BOOL)lbn;

/**
 *  设置用于定位的beacon最大个数
 *
 *  @param mbn 用于定位的beacon最大个数，即选取不多于mbn个beacon进行定位
 */
- (void)setMaxBeaconNumberForProcessing:(int)mbn;

/**
 *  设置beacon信号阈值
 *
 *  @param threshold 低于此信号阈值将忽略beacon信号
 */
- (void)setRssiThreshold:(int)threshold;

/**
 *  请求超时时间，即超过此时间没有结果返回认为定位失败
 */
@property (nonatomic, assign) float requestTimeOut;


/**
 *  当前building
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 *  定位引擎协议代理
 */
@property (nonatomic, assign) id<TYLocationManagerDelegate> delegate;

@end

/**
 *  定位引擎代理协议
 */
@protocol TYLocationManagerDelegate <NSObject>

/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 *  与[TYLocationManager:didUpdateImmediationLocation:]方法相近，此方法回调结果融合计步器信息，稳定性较好，适合用于步行场景下。
 *
 *  @param manager     定位引擎实例
 *  @param newLocation 新的位置结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateLocation:(TYLocalPoint *)newLocation;

/**
 *  定位引擎失败事件回调
 *
 *  @param manager 定位引擎实例
 *  @param error 错误信息
 */
- (void)TYLocationManager:(TYLocationManager *)manager didFailUpdateLocation:(NSError *)error;

@optional

/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 与[TYLocationManager:didUpdateLocatin:]方法相近，此方法回调结果未融合计步器信息，灵敏度较高，适合用于行车场景下
 *
 *  @param manager     定位引擎实例
 *  @param newImmediateLocation 新的位置结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateImmediateLocation:(TYLocalPoint *)newImmediateLocation;

/**
 *  Beacon扫描结果事件回调，返回符合扫描参数的所有Beacon
 *
 *  @param manager 定位引擎实例
 *  @param beacons Beacon数组，[TYBeacon]
 */
- (void)TYLocationManager:(TYLocationManager *)manager didRangedBeacons:(NSArray *)beacons;

/**
 *  定位Beacon扫描结果事件回调，返回符合扫描参数的定位Beacon，定位Beacon包含坐标信息。此方法可用于辅助巡检，以及基于定位beacon的相关触发事件。
 *
 *  @param manager 定位引擎实例
 *  @param beacons 定位Beacon数组，[TYPublicBeacon]
 */
- (void)TYLocationManager:(TYLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons;

/**
 *  设备方向改变事件回调。结合地图Api可以处理地图自动旋转，以及方向箭头等功能。
 *
 *  @param manager    定位引擎实例
 *  @param newHeading 新的设备方向结果
 */
- (void)TYLocationManager:(TYLocationManager *)manager didUpdateDeviceHeading:(double)newHeading;

@end
