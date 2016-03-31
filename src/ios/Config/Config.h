//
//  Config.h
//  CordovaApp
//
//  Created by adventis on 11/12/15.
//
// 

#import <Foundation/Foundation.h>
#import "PingDataResponse.h"

@interface Config : NSObject

@property (nonatomic, strong) NSDictionary *configDict;
@property (nonatomic, strong) NSString *configFilename;

@property (nonatomic, copy) NSString *pingUrl;
@property (nonatomic, copy) NSString *loadUrl;
@property (nonatomic, copy) NSString *loadBaseUrl;
@property (nonatomic, readwrite) BOOL enableLoadBundleCache;
@property (nonatomic, readwrite) long bundleTimestamp;
@property (nonatomic, readwrite) BOOL remoteMode;
@property (nonatomic, copy) NSString *remoteCacheId;
@property (nonatomic, readwrite) BOOL injectCordovaScripts;
@property (nonatomic, copy) NSString *pathToBundle;
@property (nonatomic, copy) NSString *openUrlScheme;
@property (nonatomic, copy) NSString *userAgentHeader;
@property (nonatomic, readwrite) BOOL isAcceptPingResponse;

-(id) initWithFilename:(NSString*) filename;
-(void) applyConfigParameters:(PingDataResponse*)response;
-(NSString*) getPingUrlServer;
-(NSString*) getPingUrlRelativePath;

@end
