//
//  QResultEncryptManager.h
//  Yang2020
//
//  Created by Igor Martsekha on 08.04.2021.
//

#import <Foundation/Foundation.h>
#import "JsonWebKey.h"
### put-here-<ProjectName>-Swift.h ###

NS_ASSUME_NONNULL_BEGIN

@interface QResultEncryptManager : NSObject
+ (id)sharedManager;
- (NSNumber*) isAllowEncryption;
- (NSString*)getPubKey;
- (NSString*) decodeRSA:(NSString*)encrypted;
- (NSNumber*) isEncrypt:(NSString*) callbackId;
- (void) setEncryptKey:(JsonWebKey*)jsonWebKey forCallback:(NSString*)callbackId andOrign:(NSString*) origin;
- (NSString*) getOriginForCallbackId:(NSString*) callbackId;
+ (NSString *)encrypt:(NSString *)plainText withKey:(NSString*)keyBase64 andIv:(NSString*)ivBase64 error:(NSError **)error;
+ (NSString *)decrypt:(NSString *)encryptedBase64String withKey:(NSString*)keyBase64 andIv:(NSString*)ivBase64 error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
