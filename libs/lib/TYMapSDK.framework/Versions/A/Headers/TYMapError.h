//
//  TYMapError.h
//  MapProject
//
//  Created by thomasho on 17/3/23.
//  Copyright © 2017年 innerpeacer. All rights reserved.
//

#ifndef TYMapError_h
#define TYMapError_h

#define TYMapErrorDomain @"com.brtbeacon.sdk"

typedef NS_ENUM(NSInteger,TYMapError) {
    TYMapLicenseInvalidError = 100,
    TYMapLoadTimeOutError,
    TYMapLoadFailError,
    TYMapDataError,
};

#endif /* TYMapError_h */
