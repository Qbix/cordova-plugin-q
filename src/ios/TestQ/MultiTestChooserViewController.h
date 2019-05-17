//
//  MultiTestChooserViewController.h
//  Shipping
//
//  Created by Home on 3/29/16.
//
//

#import <UIKit/UIKit.h>
#import "MultiTestBaseViewController.h"
#import "QWebViewController.h"


@interface MultiTestChooserViewController : MultiTestBaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) NSString *launchUrl;
- (IBAction)openUrlInWebView:(id)sender;

@end
