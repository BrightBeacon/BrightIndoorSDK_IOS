//
//  LocDataSync.m
//  mapdemo
//
//  Created by thomasho on 16/12/17.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocDataSync.h"

#import <TYLocationEngine/TYBLEEnvironment.h>
#import "ZipArchive.h"
#import <MKNetworkKit/MKNetworkKit.h>

#define getLocVersion(url) ([[NSUserDefaults standardUserDefaults] objectForKey:url])
#define setLocVersion(v,url) ([[NSUserDefaults standardUserDefaults] setObject:v forKey:url])

@interface LocDataSync ()

@end

@implementation LocDataSync

+ (void)updateLocData:(NSString *)urlNew onCompletion:(locDataCompletion)block{
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil];
	MKNetworkOperation *op = [engine operationWithURLString:urlNew];
	[op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSDictionary *rlt = [completedOperation.responseJSON valueForKey:@"rlt"];
		NSString *version = [rlt valueForKey:@"version"];
		NSString *urlZip = [rlt valueForKey:@"path"];
		if ([version isEqualToString:getLocVersion(urlZip)]) {
			block([NSError errorWithDomain:@"No Version Found" code:1 userInfo:nil]);
		}else{
			[self downloadLocZip:urlZip :version :block];
		}
	} errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
		block(error);
	}];
	[engine enqueueOperation:op];
}

+ (void)downloadLocZip:(NSString *)url :(NSString *)version :(locDataCompletion)block{
	//发现新版本，下载数据
	MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil];
	MKNetworkOperation *op = [engine operationWithURLString:url];
	[op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
		NSData *LocZipData = completedOperation.responseData;
		if (LocZipData.length) {
			NSString *LocZip = [NSTemporaryDirectory() stringByAppendingPathComponent:@"beacon.zip"];
			[LocZipData writeToFile:LocZip atomically:YES];
			//解压到指定的Loc路径
			NSString *LocPath = [TYBLEEnvironment getRootDirectoryForFiles];
			if([self unzipFile:LocZip toDir:LocPath]){
				setLocVersion(version,url);
				block(nil);
			}else{
				[[NSFileManager defaultManager] removeItemAtPath:LocZip error:nil];
				block([NSError errorWithDomain:@"unZip Failed" code:1 userInfo:nil]);
			}
		}else{
			block([NSError errorWithDomain:@"No LocZip Data" code:1 userInfo:nil]);
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
