//
//  QChooseLinkDelegate.h
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import <UIKit/UIKit.h>

@protocol QChooseLinkDelegate <NSObject>
-(void) cancelChooseLink:(NSString*) callback;
-(void) chooseLink:(NSString*) link withCallback:(NSString*) callback;
@end

