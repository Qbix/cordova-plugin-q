//
//  QDelegate.m
//  EditHTML
//
//  Created by Igor on 12/18/18.
//

#import "QDelegate.h"
#import "Q.h"

@implementation QDelegate

+(BOOL) isDebug {
#ifdef DEBUG
    return true;
#else
    return false;
#endif
}

+(void) handleLaunchMode:(CDVAppDelegate*) delegate {
    if([QDelegate isFastlaneScreenshot] || [QDelegate isDebug]) {
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
