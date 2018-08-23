//
//  TYMapError.h
//  MapProject
//
//  Created by thomasho on 17/3/23.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#ifndef TYMapError_h
#define TYMapError_h

#define TYMapErrorDomain @"TYMapErrorDomain"

/**
 *  地图错误码对照
 */
typedef NS_ENUM(NSInteger,TYMapError) {
    kTYMapErrorNone = 0,
    /** 本地权限验证失败 code = 100*/
    kTYMapErrorLicenseInvalid = 100,
    /** 本地权限过期*/
    kTYMapErrorLicenseExpired,
    /** 权限更新失败*/
    kTYMapErrorLicenseUpdateFailed,
    /** 权限更新验证失败*/
    kTYMapErrorLicenseUpdateDenied,
    /** 地图版本检查失败*/
    kTYMapErrorVersionUpdateFailed,
    /** 地图版本权限接口验证失败*/
    kTYMapErrorVersionUpdateDenied,
    /** 地图数据更新失败*/
    kTYMapErrorDataUpdateFailed,
    /** 地图数据更新接口验证失败*/
    kTYMapErrorDataUpdateDenied,
    /** 地图数据目录写入失败*/
    kTYMapErrorDataWriteFailed,
    /** 地图数据解压失败*/
    kTYMapErrorZipFailed,
    /** 地图数据读取失败*/
    kTYMapErrorDataReadingFailed
};

#endif /* TYMapError_h */
