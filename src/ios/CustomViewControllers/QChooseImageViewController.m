//
//  QChooseIMageViewController.m
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import "QChooseImageViewController.h"
#import "QWebViewController.h"

@interface QChooseImageViewController ()
@property(nonatomic, strong) QWebViewController *qWebViewController;
@end

@implementation QChooseImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClipboard:) name:UIPasteboardChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}


-(void) copyToClipboard:(NSNotification*) notification {
    UIPasteboard* clipboard = (UIPasteboard*)notification.object;
    if(clipboard != nil && clipboard.string != nil) {
        [super chooseLink:clipboard.string];
    }
}

- (void)dealloc {
    [super dealloc];
}
- (IBAction)cancelAction:(id)sender {
    [super closeAction];
}
@end
