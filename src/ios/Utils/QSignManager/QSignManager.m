//
//  QSignUtils.m
//  Qbix
//
//  Created by Igor on 6/30/17.
//
//

#import "QSignManager.h"
#import "QConfig.h"
### put-here-<ProjectName>-Swift.h ###

@implementation QSignManager

+(void) sign:(NSDictionary*) parameters withCallback:(void (^)(NSDictionary *signData, NSString *error)) callback {
    [[QSignUtils sharedInstance] sign:[[[QConfig alloc] init] applicationKey] inputParameters:parameters completion:callback];
}

@end