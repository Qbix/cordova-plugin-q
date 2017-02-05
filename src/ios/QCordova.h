#import <Cordova/CDV.h>
#import "Q.h"
#import "QChooseLinkDelegate.h"

@interface QCordova : CDVPlugin<QChooseLinkDelegate>

- (void) hello:(CDVInvokedUrlCommand*)command;

@end
