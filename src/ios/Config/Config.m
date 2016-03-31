//
//  Config.m
//  CordovaApp
//
//  Created by adventis on 11/12/15.
//
//

#import "Config.h"

@implementation Config

@synthesize configDict;
@synthesize configFilename;
@synthesize pingUrl;
@synthesize loadUrl;
@synthesize loadBaseUrl;
@synthesize enableLoadBundleCache;
@synthesize bundleTimestamp;
@synthesize remoteMode;
@synthesize injectCordovaScripts;
@synthesize pathToBundle;
@synthesize remoteCacheId;
@synthesize openUrlScheme;
@synthesize userAgentHeader;
@synthesize isAcceptPingResponse;

-(id) init {
    self = [super init];
    if (self) {
        self = [self initWithFilename:@"config"];
    }
    
    return self;
}

-(id) initWithFilename:(NSString*) filename {
    self = [super init];
    if (self) {
        self.configFilename = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
        NSError *error=nil;
        NSData *jsonData = [NSData dataWithContentsOfFile:self.configFilename options:NSDataReadingUncached error:&error];
        
        self.configDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
    }
    
    return self;
}

- (BOOL)isURL:(NSString *)inputString
{
    NSURL *temp = [NSURL URLWithString:inputString];
    return temp && temp.scheme && temp.host;
}

-(void) applyConfigParameters:(PingDataResponse*)response {
//    if(response.pingUrl != nil && [self isURL:response.pingUrl]) {
//        [self setPingUrl:response.pingUrl];
//    }
//    if(response.loadUrl != nil && [self isURL:response.loadUrl]) {
//        [self setLoadUrl:response.loadUrl];
//    }
}

-(void) saveValueToStorage:(id) value forKey:(NSString*) key {
    [self.configDict setValue:value forKey:key];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.configDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    [jsonData writeToFile:self.configFilename atomically:YES];
    

//    [self.configPlist setObject:value forKey:key];
//    [self.configPlist synchronize];
}

-(id) getValueFromStorage:(NSString*) key {
    return [self.configDict valueForKey:key];
}

#define PINGURL_FLAG @"pingUrl"
-(void)setPingUrl:(NSString *)url {
    [self saveValueToStorage:url forKey:PINGURL_FLAG];
}
-(NSString*)pingUrl {
    return [self getValueFromStorage:PINGURL_FLAG];
}
-(NSString*) getPingUrlServer {
    NSURL* url = [NSURL URLWithString:[self pingUrl]];
    return [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
}
-(NSString*) getPingUrlRelativePath {
    NSURL* url = [NSURL URLWithString:[self pingUrl]];
    return [NSString stringWithFormat:@"%@", [url path]];
}

#define LOADURL_FLAG @"loadUrl"
-(void)setLoadUrl:(NSString *)url {
    [self saveValueToStorage:url forKey:LOADURL_FLAG];
}
-(NSString*)loadUrl {
    return [self getValueFromStorage:LOADURL_FLAG];
}

#define LOADBASEURL_FLAG @"loadBaseUrl"
-(void)setLoadBaseUrl:(NSString *)url {
    [self saveValueToStorage:url forKey:LOADBASEURL_FLAG];
}
-(NSString*)loadBaseUrl {
    return [self getValueFromStorage:LOADBASEURL_FLAG];
}

#define ENABLELOADBUNDLECACHE_FLAG @"enableLoadBundleCache"
-(void)setEnableLoadBundleCache:(BOOL) status {
    [self saveValueToStorage:[NSNumber numberWithBool:status] forKey:ENABLELOADBUNDLECACHE_FLAG];
}
-(BOOL)enableLoadBundleCache {
    return [[self getValueFromStorage:ENABLELOADBUNDLECACHE_FLAG] boolValue];
}

#define BUNDLETIMESTAMP_FLAG @"bundleTimestamp"
-(void)setBundleTimestamp:(long)value {
    [self saveValueToStorage:[NSNumber numberWithLong:value] forKey:ENABLELOADBUNDLECACHE_FLAG];
}

-(long)bundleTimestamp {
    return [[self getValueFromStorage:BUNDLETIMESTAMP_FLAG] longValue];
}

#define REMOTEMODE_FLAG @"remoteMode"
-(void)setRemoteMode:(BOOL)value {
    [self saveValueToStorage:[NSNumber numberWithBool:value] forKey:REMOTEMODE_FLAG];
}

-(BOOL)remoteMode {
    return [[self getValueFromStorage:REMOTEMODE_FLAG] boolValue];
}

#define REMOTECACHEID_FLAG @"remoteCacheId"
-(void)setRemoteCacheId:(NSString*)value {
    [self saveValueToStorage:value forKey:REMOTECACHEID_FLAG];
}

-(NSString*)remoteCacheId {
    return [self getValueFromStorage:REMOTECACHEID_FLAG];
}

#define INJECTCORDOVASCRIPTS_FLAG @"remoteMode"
-(void)setInjectCordovaScripts:(BOOL)value {
    [self saveValueToStorage:[NSNumber numberWithBool:value] forKey:INJECTCORDOVASCRIPTS_FLAG];
}

-(BOOL)injectCordovaScripts {
    return [[self getValueFromStorage:INJECTCORDOVASCRIPTS_FLAG] boolValue];
}

#define PATHTOBUNDLE_FLAG @"pathToBundle"
-(void)setPathToBundle:(NSString *)path {
    [self saveValueToStorage:path forKey:PATHTOBUNDLE_FLAG];
}

-(NSString*)pathToBundle {
    return [self getValueFromStorage:PATHTOBUNDLE_FLAG];
}

#define OPENURLSCHEME_FLAG @"openUrlScheme"
-(void)setOpenUrlScheme:(NSString *)scheme {
    [self saveValueToStorage:scheme forKey:OPENURLSCHEME_FLAG];
}

-(NSString*)openUrlScheme {
    return [self getValueFromStorage:OPENURLSCHEME_FLAG];
}

#define USERAGENTHEADERSCHEME_FLAG @"userAgentHeader"
-(void)setUserAgentHeader:(NSString *)mUserAgentHeader {
    [self saveValueToStorage:mUserAgentHeader forKey:USERAGENTHEADERSCHEME_FLAG];
}

-(NSString*)userAgentHeader {
    return [self getValueFromStorage:USERAGENTHEADERSCHEME_FLAG];
}

#define ISACCEPTPINGREPONSECACHE_FLAG @"enableLoadBundleCache"
-(void)setIsAcceptPingResponse:(BOOL) status {
    [self saveValueToStorage:[NSNumber numberWithBool:status] forKey:ISACCEPTPINGREPONSECACHE_FLAG];
}
-(BOOL)isAcceptPingResponse {
    return [[self getValueFromStorage:ISACCEPTPINGREPONSECACHE_FLAG] boolValue];
}


@end
