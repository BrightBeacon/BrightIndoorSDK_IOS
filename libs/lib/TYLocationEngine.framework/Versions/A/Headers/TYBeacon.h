#import <Foundation/Foundation.h>

typedef enum type {
   UNKNOWN, PUBLIC, TRIGGER, ACTIVITY
} TYPE;

typedef enum proximity {
    TYProximityUnknown,
    TYProximityImmediate,
    TYProximityNear,
    TYProximityFar
} TYProximity;

/**
 *  图呀Beacon类
 */
@interface TYBeacon : NSObject

/**
 *  UUID
 */
@property (readonly, strong) NSString *UUID;

/**
 *  Major
 */
@property (readonly, strong) NSNumber *major;

/**
 *  Minor
 */
@property (readonly, strong) NSNumber *minor;

/**
 *  Beacon的Tag，用于标识Beacon，如Mac地址，序列号等
 */
@property (readonly, strong) NSString *tag;

/**
 *  扫描到Beacon的信号强度
 */
@property (nonatomic, assign) int rssi;

/**
 *  距离Beacon相对距离的准确性，单位为米
 */
@property (nonatomic, assign) double accuracy;

/**
 *  距离Beacon的相对距离
 */
@property (nonatomic, assign) TYProximity proximity;

/**
 *  Beacon用途类型，如用于定位、营销等
 */
@property (assign) TYPE type;


/**
 *  初始化Beacon的类方法
 *
 *  @param uuid  UUID
 *  @param major Major
 *  @param minor Minor
 *  @param tag   标识
 *
 *  @return Beacon实例
 */
+ (TYBeacon *)beaconWithUUID:(NSString *)uuid Major:(NSNumber *)major Minor:(NSNumber *)minor Tag:(NSString *)tag;

/**
 *  初始化Beacon的类方法
 *
 *  @param uuid  UUID
 *  @param major Major
 *  @param minor Minor
 *  @param tag   标识
 *  @param type  类型
 *
 *  @return Beacon实例
 */
+ (TYBeacon *)beaconWithUUID:(NSString *)uuid Major:(NSNumber *)major Minor:(NSNumber *)minor Tag:(NSString *)tag Type:(TYPE) type;

/**
 *  初始化Beacon的方法
 *
 *  @param uuid  UUID
 *  @param major Major
 *  @param minor Minor
 *  @param tag   标识
 *  @param type  类型
 *
 *  @return Beacon实例
 */
- (id)initWithUUID:(NSString *)uuid Major:(NSNumber *)major Minor:(NSNumber *)minor Tag:(NSString *)tag Type:(TYPE)type;

@end