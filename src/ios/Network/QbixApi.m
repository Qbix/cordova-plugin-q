//
//  QbixApi.m
//  QbixCordovaAppFramework
//
//  Created by Igor on 3/2/16.
//  Copyright © 2016 Qbix. All rights reserved.
//

#import "QbixApi.h"

@implementation QbixApi

//-(AFURLSessionManager*) getHTTPSessionManager {
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    return manager;
//}

//-(void)sendAsyncPingSimple {
//    NSString *post = [[NSString alloc] initWithFormat:@"udid=%@", [OpenUDID value]];
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:[[[Config alloc] init] pingUrl]]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:postData];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    if(conn) {
//            NSLog(@"Connection Successful");
//    } else {
//            NSLog(@"Connection could not be made");
//    }
//    [conn start];
//}
//
//// This method is used to receive the data which we get using post method.
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
//    NSLog(@"didReceiveData");
//}
//
//// This method receives the error report in case of connection is not made to server.
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    NSLog(@"didFailWithError");
//}
//
//// This method is used to process the data after connection has made successfully.
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"connectionDidFinishLoading");
//}
//
//-(void)sendSynchPingSimple {
//    NSString *myRequestString = [[NSString alloc] initWithFormat:@"udid=%@", [OpenUDID value]];
//    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
//    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:[[[Config alloc] init] pingUrl]]];
//    
//    [request setHTTPMethod: @"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//    [request setHTTPBody: myRequestData];
//    NSURLResponse *response;
//    NSError *err;
//    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
//    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
//    NSLog(@"responseData: %@", content);
//    
//    NSString* responseString = [[NSString alloc] initWithData:returnData encoding:NSNonLossyASCIIStringEncoding];
//    if ([content isEqualToString:responseString])
//    {
//        
//    }
//
//}
-(void) sendPing:(NSString*) url callback:(void (^)(PingDataResponse *pingdata, NSError *error))completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *requestParams = [[NSString alloc] initWithFormat:@"udid=%@", [OpenUDID value]];
    NSData *requestData = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestData];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            if([data isKindOfClass:[NSData class]]) {
                NSString* jsonResponse = [[NSString alloc] initWithData:(NSData*)data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", jsonResponse);
                NSError* err = nil;
                PingDataResponse* pingResponse = [[PingDataResponse alloc] initWithJSONString:jsonResponse];
                if(err) {
                    completionHandler(nil, error);
                } else {
                    completionHandler(pingResponse, nil);
                }
            }
        }
    }] resume];
}

//-(void) sendPing:(void (^)(PingDataResponse *pingdata, NSError *error))completionHandler {
//    
//    NSLog(@"HEllo world");
//    NSString *URLString = [[[Config alloc] init] pingUrl];
//    NSDictionary *parameters = @{@"udid": [OpenUDID value]};
//    
//    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
//    
//    NSURLSessionDataTask *dataTask = [[self getHTTPSessionManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        NSLog(@"In data task");
//        if (error) {
//            completionHandler(nil, error);
//        } else {
//            if([responseObject isKindOfClass:[NSData class]]) {
//                NSString* jsonResponse = [[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
//                NSError* err = nil;
//                PingDataResponse* pingResponse = [[PingDataResponse alloc] initWithString:jsonResponse error:&err];
//                if(err) {
//                    completionHandler(nil, error);
//                } else {
//                    completionHandler(pingResponse, nil);
//                }
//            }
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    NSLog(@"dataTask resume");
//    [dataTask resume];
//}

@end
