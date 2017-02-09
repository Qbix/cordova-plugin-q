//
//  QCustomChooseWebViewController.m
//  Pods
//
//  Created by Igor on 2/9/17.
//
//

#import "QCustomChooseWebViewController.h"

@implementation QCustomChooseWebViewController
-(void) chooseLink:(NSString*) link {
    if(self.delegate != nil)
       [self.delegate changeUrl:link];
}
-(void) chooseImage:(NSString*) image {
    if(self.delegate != nil)
    [self.delegate chooseImage:image];
}
@end
