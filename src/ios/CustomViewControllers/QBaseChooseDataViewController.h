//
//  QBaseChooseDataViewController.h
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import <UIKit/UIKit.h>
#import "QChooseLinkDelegate.h"

@protocol QBaseChooseDataViewControllerDelegate <NSObject>
-(void) changeUrl:(NSString*) newUrl;
-(void) chooseImage:(NSString*) image;
-(void) contentChanged:(NSString*) html;
@end

@interface QBaseChooseDataViewController : UIViewController<QBaseChooseDataViewControllerDelegate>
@property(nonatomic,strong) NSString *startUrl;
@property(nonatomic,strong) id<QChooseLinkDelegate> delegate;
@property(nonatomic,strong) NSString *callbackId;
@property(nonatomic, strong) NSString *currentUrl;
@property(nonatomic, strong) NSString *injectedJavascriptCode;

-(void) loadUrl:(NSString*) url;

-(void) closeAction;
-(void) chooseLink:(NSString*) url;

@end
