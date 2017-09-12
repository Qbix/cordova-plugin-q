//
//  QSignUtils.m
//  Qbix
//
//  Created by Igor on 6/30/17.
//
//

#import "QSignManager.h"
#import "QConfig.h"
#import "Groups-Swift.h"


@implementation QSignManager

+(void) sign:(NSDictionary*) parameters withCallback:(void (^)(NSDictionary *signData, NSString *error)) callback {
    [[QSignUtils sharedInstance] sign:[QConfig applicationKey] inputParameters:parameters completion:callback];
}

+(NSDictionary*) sign:(NSDictionary*) parameters {
    return [[QSignUtils sharedInstance] sign:[QConfig applicationKey] inputParameters:parameters];
}

+(NSDictionary*) signWithHmac:(NSDictionary*) parameters {
    return [[QSignUtils sharedInstance] signWithHmac:[QConfig applicationKey] inputParameters:parameters];
}

@end
