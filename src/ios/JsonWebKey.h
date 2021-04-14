//
//  JsonWebKey.h
//  Yang2020
//
//  Created by adventis on 10/28/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonWebKey : NSObject
//-(id) initWithDictionary:(NSDictionary*) dict andIV:(NSArray*) iv;
//-(id) initWithRaw:(NSArray*) key andIV:(NSArray*) iv;
-(id) initWithKey:(NSString*) key andIV:(NSString*) iv;
-(NSString*) getAlg;
-(NSString*) getKey;
-(NSString*) getIv;
//-(NSData*) getIv;
//-(NSData*) getRawKey;

@end

NS_ASSUME_NONNULL_END
