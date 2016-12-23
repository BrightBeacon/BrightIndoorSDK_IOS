//
//  BRTMapDataSync.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "MapDataSync.h"
#import <TYMapSDK/TYMapEnviroment.h>
#import "ZipArchive.h"
#import <MKNetworkKit/MKNetworkKit.h>

#define getMapVersion(url) ([[NSUserDefaults standardUserDefaults] objectForKey:url])
#define setMapVersion(v,url) ([[NSUserDefaults standardUserDefaults] setObject:v forKey:url])
@implementation MapDataSync

+ (void)updateMapData:(NSString *)urlNew onCompletion:(mapDataCompletion)block{
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil];
	MKNetworkOperation *op = [engine operationWithURLString:urlNew];
	[op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSDictionary *rlt = [completedOperation.responseJSON valueForKey:@"rlt"];

		NSString *version = [rlt valueForKey:@"version"];
		NSString *urlZip = [rlt valueForKey:@"path"];
		if ([version isEqualToString:getMapVersion(urlZip)]) {
			block([NSError errorWithDomain:@"No Version Found" code:1 userInfo:nil]);
		}else{
			[self downloadMapZip:urlZip :version :block];
		}
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
		block(error);
	}];
	[engine enqueueOperation:op];
}

+ (void)downloadMapZip:(NSString *)url :(NSString *)version :(mapDataCompletion)block{
	//发现新版本，下载数据
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil];
	MKNetworkOperation *op = [engine operationWithURLString:url];
	[op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSData *mapZipData = completedOperation.responseData;
		if (mapZipData.length) {
			NSString *mapZip = [NSTemporaryDirectory() stringByAppendingPathComponent:@"map.zip"];
			[mapZipData writeToFile:mapZip atomically:YES];
			//解压到指定的Map路径
			NSString *mapPath = [TYMapEnvironment getRootDirectoryForMapFiles];
			if([self unzipFile:mapZip toDir:mapPath]){
				setMapVersion(version,url);
				block(nil);
			}else{
				[[NSFileManager defaultManager] removeItemAtPath:mapZip error:nil];
				block([NSError errorWithDomain:@"unZip Failed" code:1 userInfo:nil]);
			}
		}else{
			block([NSError errorWithDomain:@"No MapZip Data" code:1 userInfo:nil]);
		}
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
		block(error);
	}];
	[engine enqueueOperation:op];
}

+ (BOOL)unzipFile:(NSString *)zipPath toDir:(NSString *)dir {
	NSError *err;
	[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
	if (err) {
		return NO;
	}
	//解压数据包
	BOOL status = NO;
	ZipArchive* za = [[ZipArchive alloc] init];
	if([za UnzipOpenFile:zipPath]){
		//覆盖式解压
		status = [za UnzipFileTo:dir overWrite:YES];
		[za UnzipCloseFile];
	}
	za = nil;
	return status;
}

@end
