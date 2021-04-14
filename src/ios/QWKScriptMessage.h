//
//  WKScriptMessage+BodyWriter.h
//  Yang2020
//
//  Created by Igor Martsekha on 09.04.2021.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface QWKScriptMessage : WKScriptMessage

-(id)init:(WKScriptMessage*) message andBody:(id)body;

@end

NS_ASSUME_NONNULL_END
