//
//  QCustomChooseWebViewController.h
//  Pods
//
//  Created by Igor on 2/9/17.
//
//

#import <Foundation/Foundation.h>
#import "QWebViewController.h"
#import "QBaseChooseDataViewController.h"

@interface QCustomChooseWebViewController : QWebViewController
@property(nonatomic, strong) id<QBaseChooseDataViewControllerDelegate> delegate;
-(void) chooseLink:(NSString*) link;
-(void) chooseImage:(NSString*) image;

    
@end
