#import <Cordova/CDV.h>
#import "Q.h"
#import "QChooseLinkDelegate.h"

@interface QCordova : CDVPlugin<QChooseLinkDelegate>

- (void) hello:(CDVInvokedUrlCommand*)command;
- (void)chooseLink:(CDVInvokedUrlCommand*)command;
- (void)chooseImage:(CDVInvokedUrlCommand*)command;

@end
