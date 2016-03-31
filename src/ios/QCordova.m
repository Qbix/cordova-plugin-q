#import "QCordova.h"

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
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end