//
//  NSString+SHA1.h
//  Groups
//
//  Created by Igor on 5/22/17.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (SHA1)
-(NSString*) sha1;
@end
