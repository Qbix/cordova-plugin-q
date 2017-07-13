//
//  Config.h
//  CordovaApp
//
//  Created by adventis on 11/12/15.
//
// 

#import <Foundation/Foundation.h>
#ifndef SHARE_EXTENSION
#import "PingDataResponse.h"
#endif

@interface QConfig : NSObject

@property (nonatomic, strong) NSDictionary *configDict;
@property (nonatomic, strong) NSString *configFilename;



@property (nonatomic, copy) NSString *pingUrl;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, readwrite) BOOL enableLoadBundleCache;
@property (nonatomic, readwrite) long bundleTimestamp;
@property (nonatomic, copy) NSString *cacheBaseUrl;
@property (nonatomic, readwrite) BOOL injectCordovaScripts;
@property (nonatomic, copy) NSString *pathToBundle;
@property (nonatomic, copy) NSString *openUrlScheme;
@property (nonatomic, copy) NSString *userAgentSuffix;


#ifndef SHARE_EXTENSION
-(void) applyConfigParameters:(PingDataResponse*)response;
#endif

-(id) initWithFilename:(NSString*) filename;

-(NSString*) getPingUrlServer;
-(NSString*) getPingUrlRelativePath;

+(NSString*) applicationKey;
+(NSString*) UUID;
+(NSString*) bundleID;

@end
