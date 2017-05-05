//
//  TYLocationError.h
//  TYLocationEngine
//
//  Created by thomasho on 17/5/4.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#ifndef TYLocationError_h
#define TYLocationError_h

#define TYLocationErrorDomain @"TYLocationErrorDomain"

typedef NS_ENUM(NSUInteger, TYLocationError) {
    kTYLocationErrorLicenseUpdateFailed = 100,  //权限更新失败
    kTYLocationErrorLicenseUpdateDenied,  //权限更新接口验证失败
    kTYLocationErrorVersionUpdateFailed,  //定位数据版本检查失败
    kTYLocationErrorVersionUpdateDenied,  //定位数据版本检查接口验证失败
    kTYLocationErrorDataUpdateFailed,     //定位数据更新失败
    kTYLocationErrorDataUpdateDenied,     //定位数据更新接口验证失败
    kTYLocationErrorDataZipFailed,        //定位数据文件有误
    kTYLocationErrorInvalidCode,          //定位数据校验失败
    kTYLocationErrorTimeOut               //定位超时
};

#endif /* TYLocationError_h */
