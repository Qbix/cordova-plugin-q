//
//  Config.m
//  CordovaApp
//
//  Created by adventis on 11/12/15.
//
//

#import "QConfig.h"

@implementation QConfig

@synthesize configDict;
@synthesize configFilename;
@synthesize pingUrl;
@synthesize url;
@synthesize baseUrl;
@synthesize enableLoadBundleCache;
@synthesize bundleTimestamp;
@synthesize injectCordovaScripts;
@synthesize pathToBundle;
@synthesize cacheBaseUrl;
@synthesize openUrlScheme;
@synthesize userAgentSuffix;

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
        NSDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if(error != nil)
            @throw([NSException exceptionWithName:@"Wrong JSON format" reason:@"Can't parse settings file" userInfo:nil]);
        
        NSDictionary* q = [tmpDict objectForKey:@"Q"];
        if(q == nil)
            @throw([NSException exceptionWithName:@"Didn't find need key" reason:@"Can't found Q param in settings file" userInfo:nil]);
        
        self.configDict = [q objectForKey:@"cordova"];
        if(self.configDict == nil)
            @throw([NSException exceptionWithName:@"Didn't find need key" reason:@"Can't found Q.cordova param in settings file" userInfo:nil]);
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
-(void)setPingUrl:(NSString *)_url {
    [self saveValueToStorage:_url forKey:PINGURL_FLAG];
}
-(NSString*)pingUrl {
    return [self getValueFromStorage:PINGURL_FLAG];
}
-(NSString*) getPingUrlServer {
    NSURL* _url = [NSURL URLWithString:[self pingUrl]];
    return [NSString stringWithFormat:@"%@://%@", [_url scheme], [_url host]];
}
-(NSString*) getPingUrlRelativePath {
    NSURL* _url = [NSURL URLWithString:[self pingUrl]];
    return [NSString stringWithFormat:@"%@", [_url path]];
}

#define URL_FLAG @"url"
-(void)setUrl:(NSString *) _url {
    [self saveValueToStorage:_url forKey:URL_FLAG];
}
-(NSString*)url {
    return [self getValueFromStorage:URL_FLAG];
}

#define BASEURL_FLAG @"baseUrl"
-(void)setLoadBaseUrl:(NSString *)_url {
    [self saveValueToStorage:_url forKey:BASEURL_FLAG];
}
-(NSString*)baseUrl {
    return [self getValueFromStorage:BASEURL_FLAG];
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

#define CACHEBASEURL_FLAG @"cacheBaseUrl"
-(void)setCacheBaseUrl:(NSString*)value {
    [self saveValueToStorage:value forKey:CACHEBASEURL_FLAG];
}

-(NSString*)cacheBaseUrl {
    return [self getValueFromStorage:CACHEBASEURL_FLAG];
}

#define INJECTCORDOVASCRIPTS_FLAG @"injectCordovaScripts"
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

#define USERAGENTSUFFIX_FLAG @"userAgentSuffix"
-(void)setUserAgentSuffix:(NSString *)mUserAgentSuffix {
    [self saveValueToStorage:mUserAgentSuffix forKey:USERAGENTSUFFIX_FLAG];
}

-(NSString*)userAgentSuffix {
    return [self getValueFromStorage:USERAGENTSUFFIX_FLAG];
}

+(NSString*) UUID {
    UIDevice *dev = [UIDevice currentDevice];
    return [[dev identifierForVendor] UUIDString];
}


@end
