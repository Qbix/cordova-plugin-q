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
#import "Q.h"

@interface MultiTestChooserViewController : MultiTestBaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputTextField;

@end
