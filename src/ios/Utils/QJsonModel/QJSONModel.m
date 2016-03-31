//
//  QJSONModel.m
//  QbixCordovaAppFramework
//
//  Created by Igor on 3/7/16.
//  Copyright © 2016 Qbix. All rights reserved.
//

#import "QJSONModel.h"

@implementation QJSONModel

-(id) initWithJSONString:(NSString*) jsonString {
    self = [super init];
    if(self) {
        NSError *error = nil;
        NSData *JSONData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
        
        if (!error && JSONDictionary) {
            for (NSString* key in JSONDictionary) {
                id value = [JSONDictionary valueForKey:key];
//                id objectFromClass = [self valueForKey:key];
//                if ([objectFromClass isKindOfClass:[QJSONModel class]]) {
//                    
//                }
                [self setValue:value forKey:key];
            }
            // Instead of Loop method you can also use:
            // thanks @sapi for good catch and warning.
            // [self setValuesForKeysWithDictionary:JSONDictionary];
        }
    }
    
    return self;
}


@end

