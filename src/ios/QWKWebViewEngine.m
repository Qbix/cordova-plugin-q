//
//  QWKWebViewEngine.m
//  Yang2020
//
//  Created by adventis on 10/25/19.
//

#import "QWKWebViewEngine.h"
#import "CDVRemoteInjectionWebViewBaseDelegate.h"
#import "QResultEncryptManager.h"
#import "JsonWebKey.h"
#import <CommonCrypto/CommonCrypto.h>
#import "QWKScriptMessage.h"

@interface QWKWebViewEngine()
@property(nonatomic, strong) CDVRemoteInjectionWebViewBaseDelegate* remoteInjectDelegate;
@end

@implementation QWKWebViewEngine

- (void)pluginInitialize {
    self.remoteInjectDelegate = [[CDVRemoteInjectionWebViewBaseDelegate alloc] init];
    [super pluginInitialize];
}

- (WKUserContentController*) createController {
    WKUserContentController* controller = [super createController];
    NSString *jsToInject = [self.remoteInjectDelegate buildInjectionJS];
    NSString *pubKeyBase64 = [[[[QResultEncryptManager sharedManager] getPubKey] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    jsToInject = [NSString stringWithFormat:@"window.Q_PUB_KEY='%@'; %@", pubKeyBase64, jsToInject];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsToInject injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [controller addUserScript:userScript];
    return controller;
}



- (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message
{
    QResultEncryptManager *resultEncryptManager = [QResultEncryptManager sharedManager];
    WKFrameInfo *info = message.frameInfo;
    NSString *protocol = info.securityOrigin.protocol;
    NSString *host = info.securityOrigin.host;
    NSInteger port = info.securityOrigin.port;
    
    NSString *origin = [NSString stringWithFormat:@"%@://%@:%ld", protocol, host, (long)port];
    if(port == 0) {
        origin = [NSString stringWithFormat:@"%@://%@", protocol, host];
    }
    
//    NSLog(@"message domain: %@",info.securityOrigin.host);
    NSMutableArray *decodedPayload = [NSMutableArray array];
    
    NSArray* jsonEntry = message.body; // NSString:callbackId, NSString:service, NSString:action, NSArray:args
    NSInteger counter = 4;
    if([[resultEncryptManager isAllowEncryption] boolValue]) {
        counter = 5;
    }
    
    if([jsonEntry count] != counter) {
        return;
    }
    
    NSString *callbackId = [jsonEntry objectAtIndex:0];
    NSString *aesKey = @"";
    NSString *aesIv = @"";
    if([[resultEncryptManager isAllowEncryption] boolValue]) {
        NSString *encryptedKey = [resultEncryptManager decodeRSA:[jsonEntry objectAtIndex:4]];
        NSArray *items = [encryptedKey componentsSeparatedByString:@":"];
        if([items count] != 2) {
            NSLog(@"Error to parse keys");
            return;
        }
        aesKey = [items objectAtIndex:0];
        aesIv = [items objectAtIndex:1];
        
        callbackId = [QResultEncryptManager decrypt:[jsonEntry objectAtIndex:0] withKey:aesKey andIv:aesIv error:nil];
        [decodedPayload addObject:callbackId];
        [decodedPayload addObject:[QResultEncryptManager decrypt:[jsonEntry objectAtIndex:1] withKey:aesKey andIv:aesIv error:nil]];
        [decodedPayload addObject:[QResultEncryptManager decrypt:[jsonEntry objectAtIndex:2] withKey:aesKey andIv:aesIv error:nil]];
        [decodedPayload addObject:[NSJSONSerialization
                                   JSONObjectWithData:[[QResultEncryptManager decrypt:[jsonEntry objectAtIndex:3] withKey:aesKey andIv:aesIv error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL]];
        message = [[QWKScriptMessage alloc] init:message andBody:[NSArray arrayWithArray:decodedPayload]];
    }
    
    JsonWebKey *jsonWebKey = [[JsonWebKey alloc] initWithKey:aesKey andIV:aesIv];
    [resultEncryptManager setEncryptKey:jsonWebKey forCallback:callbackId andOrign:origin];
    
    [super userContentController:userContentController didReceiveScriptMessage:message];
}




@end
