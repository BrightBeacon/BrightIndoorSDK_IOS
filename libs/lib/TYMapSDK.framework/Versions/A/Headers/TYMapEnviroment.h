//
//  TYMapEnviroment.h
//  MapProject
//
//  Created by innerpeacer on 15/2/9.
//  Copyright (c) 2015年 innerpeacer. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import <TYMapData/TYMapData.h>

/**
    地图显示的语言类型: 简体中文、繁体中文、英语
 */
typedef enum {
    TYSimplifiedChinese, TYTraditionalChinese, TYEnglish
} TYMapLanguage;


/**
 *  地图运行环境
 */
@interface TYMapEnvironment : NSObject

/**
 *  默认坐标系空间参考
 *
 *  @return WKID:3395
 */
+ (AGSSpatialReference *)defaultSpatialReference;


/**
 *  访问地图服务的默认用户验证
 *
 *  @return [user:password]
 */
+ (AGSCredential *)defaultCredential;


/**
 *  初始化运行时环境，在调用任何地图SDK方法前调用此方法
 */
+ (void)initMapEnvironment;

/**
 *  设置当前地图文件的根目录
 *
 *  @param dir 地图文件根目录
 */
+ (void)setRootDirectoryForMapFiles:(NSString *)dir;

/**
 *  获取当前地图文件的根目录
 *
 *  @return 根目录路径
 */
+ (NSString *)getRootDirectoryForMapFiles;

/**
 *  获取目标建筑的目录路径
 *
 *  @param building 目标建筑
 *
 *  @return 目标建筑的文件路径
 */
+ (NSString *)getBuildingDirectory:(TYBuilding *)building;

/**
 *  设置当前地图显示的语言类型
 *
 *  @param language 目标语言类型
 */
+ (void)setMapLanguage:(TYMapLanguage)language;

/**
 *  获取当前地图显示的语言类型
 *
 *  @return 当前语言类型
 */
+ (TYMapLanguage)getMapLanguage;

/**
 *  设置地图服务网络接口主机名
 *
 *  @param hostName 主机名
 */
+ (void)setHostName:(NSString *)hostName;

/**
 *  获取地图服务网络接口主机名
 *
 *  @return 主机名
 */
+ (NSString *)getHostName;

@end
