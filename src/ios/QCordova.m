#import "QCordova.h"
#import "QChooseLinkViewController.h"
#import "QChooseImageViewController.h"


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
    NSString* initUrl = [[command arguments] objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QCustomVCStoryboard" bundle:nil];
    UINavigationController *qChooseLinkNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"QChooseLinkViewControllerNavigation"];
    
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setStartUrl:initUrl];
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setDelegate:self];
    [(QChooseLinkViewController*)[qChooseLinkNavigationController.viewControllers firstObject] setCallbackId:callbackId];
    
    [self.viewController presentModalViewController:qChooseLinkNavigationController animated:NO];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (void)chooseImage:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* initUrl = [[command arguments] objectAtIndex:0];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QCustomVCStoryboard" bundle:nil];
    UINavigationController *qChooseImageNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"QChooseImageViewControllerNavigation"];
    
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setStartUrl:initUrl];
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setDelegate:self];
    [(QChooseImageViewController*)[qChooseImageNavigationController.viewControllers firstObject] setCallbackId:callbackId];
    
    [self.viewController presentModalViewController:qChooseImageNavigationController animated:NO];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

-(void) cancelChooseLink:(NSString*) callbackId {
    if(callbackId != nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cancel"];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

-(void) chooseLink:(NSString*) url withCallback:(NSString*) callbackId {
    if(callbackId != nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:url];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

@end
