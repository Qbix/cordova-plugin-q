//
//  QDelegate.m
//  EditHTML
//
//  Created by Igor on 12/18/18.
//

#import "QDelegate.h"
#import "Q.h"

@implementation QDelegate

+(void) handleLaunchMode:(CDVAppDelegate*) delegate {
    if([QDelegate isFastlaneScreenshot]) {
        [Q initTestWith:delegate];
    } else {
        [Q initWith:delegate];
        [[Q getInstance] showQWebView];
    }
}

+(void) resetApp {
    [[Q getInstance] resetTestMode];
}

+(BOOL) isFastlaneScreenshot {
    return [[[NSProcessInfo processInfo] environment] objectForKey:@"Fastlane"] != nil;
}

@end
