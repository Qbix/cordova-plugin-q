//
//  FileSystemHelper.h
//  QGroupsTest
//
//  Created by adventis on 10/7/15.
//
//

#import <Foundation/Foundation.h>

@interface FileSystemHelper : NSObject
+(NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath;
@end
