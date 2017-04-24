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
//typedef NS_ENUM(NSInteger, TYMapError) {
//    kTYErrorLocationUnknown  = 0,         // location is currently unknown, but TY will keep trying
//    kTYErrorDenied,                       // Access to location or ranging has been denied by the user
//    kTYErrorNetwork,                      // general, network-related error
//    kTYErrorHeadingFailure,               // heading could not be determined
//    kTYErrorRegionMonitoringDenied,       // Location region monitoring has been denied by the user
//    kTYErrorRegionMonitoringFailure,      // A registered region cannot be monitored
//    kTYErrorRegionMonitoringSetupDelayed, // TY could not immediately initialize region monitoring
//    kTYErrorRegionMonitoringResponseDelayed, // While events for this fence will be delivered, delivery will not occur immediately
//    kTYErrorGeocodeFoundNoResult,         // A geocode request yielded no result
//    kTYErrorGeocodeFoundPartialResult,    // A geocode request yielded a partial result
//    kTYErrorGeocodeCanceled,              // A geocode request was cancelled
//    kTYErrorDeferredFailed,               // Deferred mode failed
//    kTYErrorDeferredNotUpdatingLocation,  // Deferred mode failed because location updates disabled or paused
//    kTYErrorDeferredAccuracyTooLow,       // Deferred mode not supported for the requested accuracy
//    kTYErrorDeferredDistanceFiltered,     // Deferred mode does not support distance filters
//    kTYErrorDeferredCanceled,             // Deferred mode request canceled a previous request
//    kTYErrorRangingUnavailable,           // Ranging cannot be performed
//    kTYErrorRangingFailure,               // General ranging failure
//};

#endif /* TYMapError_h */
