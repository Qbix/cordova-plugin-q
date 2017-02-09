//
//  QBaseChooseDataViewController.m
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import "QBaseChooseDataViewController.h"
#import "QWebViewController.h"

@interface QBaseChooseDataViewController ()
@property(nonatomic, strong) QWebViewController *qWebViewController;

@end

@implementation QBaseChooseDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"QWebViewSegue"]) {
        [self setQWebViewController:(QWebViewController*)segue.destinationViewController];
        [self loadUrl:self.startUrl];
    }
}

-(void) loadUrl:(NSString*) url {
    [self setCurrentUrl:url];
    [self.qWebViewController loadUrl:url];
}

-(void) closeAction {
    if(self.delegate != nil) {
        [self.delegate cancelChooseLink:self.callbackId];
    }
    self.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) chooseLink:(NSString*) url {
    if(self.delegate != nil) {
        [self.delegate chooseLink:url withCallback:self.callbackId];
    }
    self.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)dealloc {
//    [self.qWebViewController release];
//    [super dealloc];
//}

@end
