#import "QCordova.h"
#import "QChooseLinkViewController.h"
#import "QChooseImageViewController.h"
#import "QCustomChooseWebViewController.h"
#import "QSignManager.h"

@interface QCordova()
    @property(nonatomic, strong) NSString *callbackId;
    @property(nonatomic, strong) UIViewController *customController;
@end

@implementation QCordova

- (void)pluginInitialize
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpenURLOptionsSourceApplicationKey:) name:CDVPluginHandleOpenURLNotification object:nil];
}

//- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification
//{
//    CDVAppDelegate *appDelegate = [[notification object] delegate];
//	[Q initWith:appDelegate];
//}

- (void)applicationOpenURLOptionsSourceApplicationKey:(NSNotification *)notification
{
    if([notification object]!= nil && [[notification object] isKindOfClass:[NSURL class]]) {
        [[Q getInstance] handleOpenUrlScheme:[notification object]];
    }
}

- (void)hello:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* msg = @"Hello, from Q";

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)chooseLink:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    [self setCallbackId:callbackId];
    NSString* initUrl = [[command arguments] objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QCustomVCStoryboard" bundle:nil];
    UINavigationController *qChooseLinkNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"QChooseLinkViewControllerNavigation"];
    
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setStartUrl:initUrl];
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setDelegate:self];
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setCallbackId:callbackId];
    
    [self setCustomController:qChooseLinkNavigationController];
    [self.viewController presentModalViewController:qChooseLinkNavigationController animated:NO];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)chooseImage:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    [self setCallbackId:callbackId];
    NSString* initUrl = [[command arguments] objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QCustomVCStoryboard" bundle:nil];
    UINavigationController *qChooseImageNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"QChooseImageViewControllerNavigation"];
    
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setStartUrl:initUrl];
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setDelegate:self];
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setCallbackId:callbackId];
    
    [self setCustomController:qChooseImageNavigationController];
    [self.viewController presentModalViewController:qChooseImageNavigationController animated:NO];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}
    
- (void)changeInnerUrlEvent:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSString* url = [[command arguments] objectAtIndex:0];
    
    if([self.viewController isKindOfClass:[QCustomChooseWebViewController class]]) {
        [(QCustomChooseWebViewController*)self.viewController chooseLink:url];
    }
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}
    
- (void)chooseImageEvent:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSString* url = [[command arguments] objectAtIndex:0];
    
    if([self.viewController isKindOfClass:[QCustomChooseWebViewController class]]) {
        [(QCustomChooseWebViewController*)self.viewController chooseImage:url];
    }
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)sign:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSDictionary* parameters = [[command arguments] objectAtIndex:0];
    
    [QSignManager sign:parameters withCallback:^(NSDictionary *signData, NSString *error) {
        CDVPluginResult* result = nil;
        if(!error) {
            result = [CDVPluginResult
                      resultWithStatus:CDVCommandStatus_OK messageAsDictionary:signData];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }];
}

- (void)info:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    NSDictionary* params = @{
                             @"Q.appId":[QConfig UUID],
                             @"Q.udid":[QConfig bundleID]
                             };
    
    CDVPluginResult* result = [CDVPluginResult
     resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
    
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

//changeInnerUrlEvent: function(url, successCallback, errorCallback) {
//    cordova.exec(successCallback, errorCallback, "QCordova", "changeInnerUrlEvent", [url]);
//},
//chooseImageEvent: function(image, successCallback, errorCallback) {
//    cordova.exec(successCallback, errorCallback, "QCordova", "chooseImageEvent", [image]);
//}

-(void) cancelChooseLink:(NSString*) callbackId {
    if(callbackId != nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cancel"];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

-(void) chooseLink:(NSString*) url withCallback:(NSString*) callbackId {
    if(callbackId != nil) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:url forKey:@"link"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

-(void) contentChanged:(NSString *)html withCallback:(NSString *)callbackId {
    if(callbackId != nil) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:html forKey:@"html"];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

@end
