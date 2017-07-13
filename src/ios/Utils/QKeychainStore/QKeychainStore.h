//
//  QKeychainStore.h
//  Groups
//
//  Created by Igor on 7/10/17.
//
//

#import <Foundation/Foundation.h>

@interface QKeychainStore : NSObject

-(instancetype)initShareKeychainWithService:(NSString*) service andAppGroupId:(NSString*) appGroupId;

-(void) deleteEntryForKey:(NSString*) key;

-(void) setString:(NSString*) value forKey:(NSString*) key;
-(void) setBool:(BOOL) value forKey:(NSString*) key;
-(BOOL) boolforKey:(NSString*) key;
@end
