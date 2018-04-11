//
//  MultiTestBaseViewController.h
//  Shipping
//
//  Created by Home on 3/29/16.
//
//

#import <UIKit/UIKit.h>

@interface MultiTestBaseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
-(NSURL*) getNSURLFromString:(NSString*) rawUrl;
-(void) addNewBookmark:(NSString*) newBookmark;

@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
