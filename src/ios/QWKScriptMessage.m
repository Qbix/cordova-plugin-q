//
//  WKScriptMessage+BodyWriter.m
//  Yang2020
//
//  Created by Igor Martsekha on 09.04.2021.
//

#import "QWKScriptMessage.h"

@interface QWKScriptMessage()
@property (nonatomic, strong) id body;
@property (nullable, nonatomic, weak) WKWebView *webView;
@property (nonatomic, assign) WKFrameInfo *frameInfo;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) WKContentWorld *world API_AVAILABLE(macos(11.0), ios(14.0));

@end

@implementation QWKScriptMessage

@synthesize body;
@synthesize webView;
@synthesize frameInfo;
@synthesize name;
@synthesize world;

-(id)init:(WKScriptMessage*) message andBody:(id)body {
    self = [super init];
    if(self) {
        self.body = body;
        self.name = message.name;
        self.webView = message.webView;
        self.frameInfo = message.frameInfo;
        self.world = message.world;
    }
    return self;
}
@end
