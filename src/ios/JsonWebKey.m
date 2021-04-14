//
//  JsonWebKey.m
//  Yang2020
//
//  Created by adventis on 10/28/19.
//

#import "JsonWebKey.h"

@interface JsonWebKey()
@property(nonatomic, strong) NSString *innerKey;
@property(nonatomic, strong) NSString *innerIv;
@property(nonatomic, strong) NSString *innerAlg;
@end

@implementation JsonWebKey

-(id) initWithKey:(NSString*) key andIV:(NSString*) iv {
    self = [super init];
    if(self) {
        [self setInnerKey:key];
        [self setInnerIv:iv];
    }
    return self;
}

//-(id) initWithRaw:(NSArray*) key andIV:(NSArray*) iv {
//    self = [super init];
//    if(self) {
//        NSMutableData *keyMutableData = [NSMutableData data];
//        for(NSNumber* item in key) {
//            unsigned char shortNumber = [item unsignedCharValue];
//            NSData *itemData = [NSData dataWithBytes:&shortNumber length:1];
//            [keyMutableData appendData:itemData];
//        }
//        [self setRawInnerKey:[keyMutableData copy]];
//        NSMutableData *ivMutableData = [NSMutableData data];
//        for(NSNumber* item in iv) {
//            unsigned char shortNumber = [item unsignedCharValue];
//            NSData *itemData = [NSData dataWithBytes:&shortNumber length:1];
//            [ivMutableData appendData:itemData];
//        }
//        [self setIvData:[ivMutableData copy]];
//
//        if(_rawInnerKey == nil || _ivData == nil) {
//            @throw [NSException exceptionWithName:@"Invalid json format"
//              reason:@"Invalid json format"
//            userInfo:nil];
//        }
//    }
//    return self;
//}

//-(id) initWithDictionary:(NSDictionary*) dict andIV:(NSArray*) iv {
//    self = [super init];
//    if(self) {
//        if([dict objectForKey:@"alg"] != nil) {
//            [self setInnerAlg:[dict objectForKey:@"alg"]];
//        }
//        if([dict objectForKey:@"k"] != nil) {
//            [self setInnerKey:[dict objectForKey:@"k"]];
//        }
//        NSMutableData *ivMutableData = [NSMutableData data];
//        for(NSNumber* item in iv) {
//            unsigned char shortNumber = [item unsignedCharValue];
//            NSData *itemData = [NSData dataWithBytes:&shortNumber length:1];
//            [ivMutableData appendData:itemData];
//        }
//        [self setIvData:[ivMutableData copy]];
//
//        if(_innerKey == nil || _innerAlg == nil || _ivData == nil) {
//            @throw [NSException exceptionWithName:@"Invalid json format"
//              reason:@"Invalid json format"
//            userInfo:nil];
//        }
//    }
//    return self;
//}

-(NSString*) getAlg {
    return _innerAlg;
}
-(NSString*) getKey {
    return _innerKey;
}
-(NSString*) getIv {
    return _innerIv;
}
//-(NSData*) getRawKey {
//    return _rawInnerKey;
//}
//-(NSData*) getIv {
//    return _ivData;
//}

@end
