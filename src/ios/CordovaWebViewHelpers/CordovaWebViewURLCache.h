//
//  CordovaWebViewURLCache.h
//  QGroupsTest
//
//  Created by adventis on 10/6/15.
//
//

#import <Foundation/Foundation.h>

@interface CordovaWebViewURLCache : NSURLCache

@property(nonatomic, retain) NSArray *listOfJsInjects;
@property(nonatomic) BOOL isReturnCahceFilesFromBundle;
@property(nonatomic, copy) NSString *pathToBundle;
@property(nonatomic, copy) NSString *remoteCacheId;

@end
