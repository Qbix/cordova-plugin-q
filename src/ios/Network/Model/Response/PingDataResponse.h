//
//  PingResponse.h
//  CordovaApp
//
//  Created by adventis on 11/12/15.
//
//

#import <Foundation/Foundation.h>
#import "QJSONModel.h"

@interface PingDataResponse : QJSONModel
    @property (nonatomic, assign) NSString *pingUrl;
    @property (nonatomic, assign) NSString *loadUrl;
//    @property (nonatomic, assign) long timestamp;
//    @property (assign, nonatomic) BOOL webmode;
//    @property (assign, nonatomic) Sticky *stickyo;
//    @property (assign, nonatomic) PingStatusModel *status;
@end
