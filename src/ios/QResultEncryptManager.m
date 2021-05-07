//
//  QResultEncryptManager.m
//  Yang2020
//
//  Created by adventis on 10/25/19.
//

#import "QResultEncryptManager.h"
#import "JsonWebKey.h"
#import <CommonCrypto/CommonCryptor.h>
### put-here-<ProjectName>-Swift.h ###

@interface QResultEncryptManager()
@property(nonatomic, strong) NSMutableDictionary<NSString*, NSMutableDictionary<NSString*,JsonWebKey*>*>* originsEncryptTable;
@property(nonatomic, strong) QCryptoRSAManager *qCryptoRSAManager;
@end

@implementation QResultEncryptManager

+ (id)sharedManager {
    static QResultEncryptManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

-(id) init {
    self = [super init];
    if(self) {
        self.originsEncryptTable = [NSMutableDictionary dictionary];
        self.qCryptoRSAManager = [QCryptoRSAManager sharedInstance];
    }
    return self;
}

-(NSString*) getPubKey {
    return [self.qCryptoRSAManager getExportedPublicKey];
}

-(NSString*) decodeRSA:(NSString*)encryptedBase64 {
    NSData* encryptedData = [[NSData alloc] initWithBase64EncodedString:encryptedBase64 options:0];
    return [self.qCryptoRSAManager decryptMessageWithPrivateKey:encryptedData];
}

-(NSString*) encrypt:(NSString*) data forCallbackId:(NSString*) callbackId {
    JsonWebKey* jsonWebKey = [self getJsonWebKeyForCallbackId:callbackId];
    if(jsonWebKey == nil) {
        return nil;
    }

    NSError *error = nil;
//    NSLog(@"ENCRYPT. Key:%@; IV:%@", [jsonWebKey getKey],[jsonWebKey getIv]);
    NSString* encryptedKey = [QResultEncryptManager encrypt:data withKey:[jsonWebKey getKey] andIv:[jsonWebKey getIv] error:&error];
    return encryptedKey;
}

-(NSNumber*) isAllowEncryption {
    return [[NSNumber alloc] initWithBool:YES];
}

-(NSNumber*) isEncrypt:(NSString*) callbackId {
    return [self isAllowEncryption];
}

-(void) setEncryptKey:(JsonWebKey*)jsonWebKey forCallback:(NSString*)callbackId andOrign:(NSString*) origin {
    NSMutableDictionary<NSString*, JsonWebKey*>* encryptMap = [self getDictionaryForOrigin:origin];
    [encryptMap setValue:jsonWebKey forKey:callbackId];
}

-(JsonWebKey*) getJsonWebKeyForCallbackId:(NSString*) callbackId {
    for(NSString* origin in [self.originsEncryptTable allKeys]) {
        NSMutableDictionary<NSString*, JsonWebKey*>* encryptMap = [self getDictionaryForOrigin:origin];
        if([encryptMap valueForKey:callbackId] != nil) {
            return [encryptMap valueForKey:callbackId];
        }
    }
    return nil;
}

-(NSString*) getOriginForCallbackId:(NSString*) callbackId {
    for(NSString* origin in [self.originsEncryptTable allKeys]) {
        NSMutableDictionary<NSString*, JsonWebKey*>* encryptMap = [self getDictionaryForOrigin:origin];
        if([encryptMap valueForKey:callbackId] != nil) {
            return origin;
        }
    }
    return nil;
}

-(NSMutableDictionary<NSString*,JsonWebKey*>*) getDictionaryForOrigin:(NSString*) origin {
    NSMutableDictionary<NSString*, JsonWebKey*> *encryptMap = [self.originsEncryptTable objectForKey:origin];
    if(encryptMap == nil) {
        encryptMap = [NSMutableDictionary dictionary];
        [self.originsEncryptTable setValue:encryptMap forKey:origin];
    }
    return encryptMap;
}

+ (NSString *)encrypt:(NSString *)plainText withKey:(NSString*)keyBase64 andIv:(NSString*)ivBase64 error:(NSError **)error {
    NSData* key = [[NSData alloc] initWithBase64EncodedString:keyBase64 options:0];
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:ivBase64 options:0];
    NSMutableData *result =  [QResultEncryptManager doAES:[plainText dataUsingEncoding:NSUTF8StringEncoding] withKey:key andIv:iv context:kCCEncrypt error:error];
    NSString* encrypted64 = [result base64EncodedStringWithOptions:0];
//    NSLog(@"Encrypted : %@",encrypted64);
    return encrypted64;
}


+ (NSString *)decrypt:(NSString *)encryptedBase64String withKey:(NSString*)keyBase64 andIv:(NSString*)ivBase64 error:(NSError **)error {
    NSData* key = [[NSData alloc] initWithBase64EncodedString:keyBase64 options:0];
    NSData* iv = [[NSData alloc] initWithBase64EncodedString:ivBase64 options:0];
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:encryptedBase64String options:0];
    NSMutableData *result = [QResultEncryptManager doAES:dataToDecrypt withKey:key andIv:iv context:kCCDecrypt error:error];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

+ (NSMutableData *)doAES:(NSData *)dataIn withKey:(NSData*) key andIv:(NSData*)iv context:(CCOperation)kCCEncrypt_or_kCCDecrypt error:(NSError **)error {
    if(kCCEncrypt_or_kCCDecrypt == kCCDecrypt) {
        NSMutableData* decrypted = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
        size_t bytesDecrypted = 0;
        CCCrypt(kCCDecrypt,
                kCCAlgorithmAES128,
                kCCOptionPKCS7Padding,
                key.bytes,
                key.length,
                iv.bytes,
                dataIn.bytes, dataIn.length,
                decrypted.mutableBytes, decrypted.length, &bytesDecrypted);
            return [NSMutableData dataWithBytes:decrypted.mutableBytes length:bytesDecrypted];
    } else {
        NSMutableData* encrypted = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
        size_t bytesEncrypted = 0;
        CCCrypt(kCCEncrypt,
                kCCAlgorithmAES128,
                kCCOptionPKCS7Padding,
                key.bytes,
                key.length,
                iv.bytes,
                dataIn.bytes, dataIn.length,
                encrypted.mutableBytes, encrypted.length, &bytesEncrypted);
        return [NSMutableData dataWithBytes:encrypted.mutableBytes length:bytesEncrypted];
    }
}

@end
