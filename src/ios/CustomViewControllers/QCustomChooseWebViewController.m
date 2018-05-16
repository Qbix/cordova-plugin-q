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

- (void)webViewDidFinishLoad:(UIWebView*)theWebView {
    [super webViewDidFinishLoad:theWebView];
    
    NSString *html = [[super getWebView] stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    if(self.delegate != nil)
        [self.delegate contentChanged:html];
}

- (void)dealloc {
#if __has_feature(objc_arc)
    
#else
    [super dealloc];
#endif
}

@end
