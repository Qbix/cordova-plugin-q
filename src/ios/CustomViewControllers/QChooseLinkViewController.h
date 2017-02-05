//
//  ChooseLinkViewController.h
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import <UIKit/UIKit.h>
#import "QBaseChooseDataViewController.h"

@interface QChooseLinkViewController : QBaseChooseDataViewController
- (IBAction)closeAction:(id)sender;
- (IBAction)chooseAction:(id)sender;
- (IBAction)urlBeginEdit:(id)sender;
- (IBAction)urlEndEdit:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *urlEditText;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *chooseBtn;

@end
