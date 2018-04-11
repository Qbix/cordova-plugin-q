//
//  QKeychainStore.m
//  Groups
//
//  Created by Igor on 7/10/17.
//
//

#import "QKeychainStore.h"
#import <SimpleKeychain/SimpleKeychain.h>

@interface QKeychainStore()
@property(nonatomic, strong) A0SimpleKeychain* keychain;
@end

@implementation QKeychainStore

- (instancetype)init {
    if(self = [super init]) {
        _keychain = [A0SimpleKeychain keychain];
    }
    return self;
}

-(instancetype)initShareKeychainWithService:(NSString*) service andAppGroupId:(NSString*) appGroupId {
    if(self = [super init]) {
        _keychain = [[A0SimpleKeychain keychainWithService:service accessGroup:appGroupId] retain];
    }
    return self;
    
}

-(void) deleteEntryForKey:(NSString*) key {
    [_keychain deleteEntryForKey:key];
}

-(void) setString:(NSString*) value forKey:(NSString*) key {
    [_keychain setString:value forKey:key];
}

-(void) setBool:(BOOL) value forKey:(NSString*) key {
    [_keychain setString:(value ? @"YES":@"NO") forKey:key];
}

-(BOOL) boolforKey:(NSString*) key {
    NSString * value = [_keychain stringForKey:key];
    if(value != nil && [value isEqualToString:@"YES"]) {
        return YES;
    }
    
    return NO;
}


@end
