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
        NSString *initUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"init_url"];
        [Q initTestWith:delegate andInitUrl:initUrl];
    } else {
        [Q initWith:delegate]; //added this line in first'
        [[Q getInstance] showQWebView];
    }
}

+(BOOL) isFastlaneScreenshot {
    return [[[NSProcessInfo processInfo] environment] objectForKey:@"Fastlane"] != nil;
}

@end
