//
//  QChooseIMageViewController.h
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import <UIKit/UIKit.h>
#import "QBaseChooseDataViewController.h"

@interface QChooseImageViewController : QBaseChooseDataViewController
- (IBAction)cancelAction:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *bottomImageSelectHint;
@property(nonatomic, strong) NSString* injectScript;


@end
