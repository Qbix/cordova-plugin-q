//
//  Q.m
//  CordovaApp
//
//  Created by adventis on 12/3/15.
//
//

#import "Q.h"
#import "QSignManager.h"
#import "MultiTestChooserViewController.h"
#import "MultiTestUINavigationController.h"

@implementation Q
#define CACHE_SIZE_MEMORY 8*1024*1024
#define CACHE_SIZE_DISK 32*1024*1024

@synthesize appDelegate;

static Q *instance = nil;

+ (Q*)initTestWith:(CDVAppDelegate *)appDelegate {
    return [Q initTestWith:appDelegate andInitUrl:nil];
}

+ (Q*)initTestWith:(CDVAppDelegate *)appDelegate andInitUrl:(NSString*) url {
    if (instance == nil) {
        instance = [[super alloc] init];
    }
    [instance setAppDelegate:appDelegate];
    [instance initializeTestWithUrl:url];
    
    return instance;
}

+ (Q*)initWith:(CDVAppDelegate *)appDelegate {
    if (instance == nil) {
        instance = [[super alloc] init];
    }
    [instance setAppDelegate:appDelegate];
    [instance initialize];
    
    return instance;
}

+(Q*) getInstance {
    if(instance == nil) {
        @throw [[NSException alloc] initWithName:@"Q plugin isn't inited. Please run static method initWith:(CDVAppDelegate *)appDelegate" reason:@"" userInfo:nil];
        return nil;
    }
    
    return instance;
}


-(void) initialize {
    [self initSharedCache];
    
    if([self.appDelegate respondsToSelector:@selector(viewController)]) {
        self.appDelegate.viewController.baseUserAgent = [NSString stringWithFormat:@"%@ %@",self.appDelegate.viewController.baseUserAgent, [[[QConfig alloc] init] userAgentSuffix] ];
    }
    
    [self sendPingRequest];
    
}

-(void) showQWebView {
    self.appDelegate.viewController = [self prepeareQGroupsController];
}

-(void) resetTestMode {
    UIStoryboard *testStoryboard = [UIStoryboard storyboardWithName:@"QTestStoryboard" bundle:nil];
    MultiTestUINavigationController *navigationController = (MultiTestUINavigationController*)[testStoryboard instantiateInitialViewController];
    [(MultiTestChooserViewController*)navigationController.viewControllers[0] setLaunchUrl:nil];
    self.appDelegate.window.rootViewController = (CDVViewController*)navigationController;
    [self.appDelegate.window makeKeyAndVisible];
}

-(void) initializeTestWithUrl:(NSString*) url {
    [self initSharedCache];
    
    UIStoryboard *testStoryboard = [UIStoryboard storyboardWithName:@"QTestStoryboard" bundle:nil];
    MultiTestUINavigationController *navigationController = (MultiTestUINavigationController*)[testStoryboard instantiateInitialViewController];
    [(MultiTestChooserViewController*)navigationController.viewControllers[0] setLaunchUrl:url];
    self.appDelegate.viewController = (CDVViewController*)navigationController;
}

-(void) sendPingRequest {
    //    [[[QbixApi alloc] init] sendAnotherPing:^(PingDataResponse* response, NSError* error) {
    //        NSLog(@"Response");
    //    }];
}

-(void) initSharedCache {
    CordovaWebViewURLCache* sharedCache = [self prepeareCordovaWebViewUrlCacheMemory:CACHE_SIZE_MEMORY andDisk:CACHE_SIZE_DISK];
    [NSURLCache setSharedURLCache:sharedCache];
}

-(CordovaWebViewURLCache*) prepeareCordovaWebViewUrlCacheMemory:(int) cache_size_memory andDisk:(int) cache_size_disk {
    QConfig *conf = [[QConfig alloc] init];
    
    CordovaWebViewURLCache* sharedCache = [[CordovaWebViewURLCache alloc] initWithMemoryCapacity:cache_size_memory diskCapacity:cache_size_disk diskPath:@"nsurlcache"];
    
    [sharedCache setIsReturnCahceFilesFromBundle:[conf enableLoadBundleCache]];
    [sharedCache setPathToBundle:[conf pathToBundle]];
    [sharedCache setRemoteCacheId:[conf cacheBaseUrl]];
    
    // Cordova plugins inject by separate plugin
    // if([conf injectCordovaScripts]) {
    //     NSMutableArray *filesToInject = [NSMutableArray array];
        
    //     // add cordova.js file 
    //     [filesToInject addObject:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"cordova.js"]];
    //     // add cordova_plugins.js files with all plugins
    //     [filesToInject addObject:[NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"cordova_plugins.js"]];
        
    //     // add another files
    //     NSString *pathToCordovaPlugins = [NSString stringWithFormat:@"%@/%@%@", [[NSBundle mainBundle] resourcePath], @"www/", @"plugins"];
    //     [filesToInject addObjectsFromArray:[QFileSystemHelper recursivePathsForResourcesOfType:@"js" inDirectory:pathToCordovaPlugins]];
        
    //     [sharedCache setListOfJsInjects:filesToInject];
    // }
    
    return sharedCache;
}

- (QWebViewController*) prepeareQGroupsController {
    QConfig *conf = [[QConfig alloc] init];
    
    return [[QWebViewController alloc] initWithUrl:[conf url] andParameters:[self getAdditionalParamsForUrl]];
}

- (QWebViewController*) prepeareQWebViewControllerWith:(NSString*) url {
    return [[QWebViewController alloc] initWithUrl:url andParameters:[self getAdditionalParamsForUrl]];
}

- (NSString*) getSystemLanguage{
    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([preferredLang length] >= 2) {
        preferredLang = [preferredLang substringWithRange:NSMakeRange(0, 2)];
    }
    return preferredLang;
}

-(NSDictionary*) getAdditionalParamsForUrl {
    QConfig *conf = [[QConfig alloc] init];
    NSMutableDictionary *paramsLoadUrl = [NSMutableDictionary dictionary];
    [paramsLoadUrl setObject:[NSString stringWithString:[QConfig UUID]] forKey:@"Q.udid"];
    [paramsLoadUrl setObject:[NSString stringWithString:CDV_VERSION] forKey:@"Q.cordova"];
    [paramsLoadUrl setObject:[QConfig bundleID] forKey:@"Q.appId"];
    [paramsLoadUrl setObject:[self getSystemLanguage] forKey:@"Q.language"];
    
    
//    //Add signature for request
//    NSNumber *timestamp = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
//    NSString *unEncodedSignature = [NSString stringWithFormat:@"%@%@",[QConfig UUID], [timestamp stringValue]];
//    [paramsLoadUrl setObject:timestamp forKey:@"Q.t"];
//    [paramsLoadUrl setObject:[unEncodedSignature sha1] forKey:@"Q.sig"];

    if([conf enableLoadBundleCache]) {
        [paramsLoadUrl setObject:[NSNumber numberWithLong:[conf bundleTimestamp]] forKey:@"Q.ct"];
    }
    
    NSDictionary *signParameters = [QSignManager sign:[paramsLoadUrl copy]];
    
    return signParameters;
}

-(void)handleOpenUrlScheme:(NSURL*)url {
    QConfig* conf = [[QConfig alloc] init];

    if([[url scheme] isEqualToString:[conf openUrlScheme]]) {
    
        NSDictionary *customParamsDict = [self getAdditionalParamsForUrl];
        NSString *customParams = @"";
        for (NSString* key in customParamsDict) {
            id value = [customParamsDict objectForKey:key];
            if(value != nil)
                customParams = [customParams stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, (NSString*)value]];
        }
        
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@?%@%@#%@", [conf baseUrl], [url path], customParams, [url query], [url fragment]];
        
        NSString *fragment = [url fragment];
        if([fragment isEqualToString:@"newWindow"]) {
            //Open in additional webview
        } else {
            //Open in main webview
        }
    }
}

@end
