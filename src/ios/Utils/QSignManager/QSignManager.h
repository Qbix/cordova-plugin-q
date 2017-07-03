//
//  QSignUtils.h
//  Qbix
//
//  Created by Igor on 6/30/17.
//
//

#import <Foundation/Foundation.h>

@interface QSignManager : NSObject

+(void) sign:(NSDictionary*) parameters withCallback:(void (^)(NSDictionary *signData, NSString *error)) callback;

@end
