//
//  QbixApi.h
//  QbixCordovaAppFramework
//
//  Created by Igor on 3/2/16.
//  Copyright © 2016 Qbix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PingDataResponse.h"

@interface QbixApi : NSObject

-(void) sendPing:(NSString*) url callback:(void (^)(PingDataResponse *pingdata, NSError *error))completionHandler;

@end
