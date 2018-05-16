//
//  QBaseChooseDataViewController.m
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import "QBaseChooseDataViewController.h"
#import "QWebViewController.h"
#import "QCustomChooseWebViewController.h"

@interface QBaseChooseDataViewController ()
@property(nonatomic, strong) QCustomChooseWebViewController *qWebViewController;

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
        [self setQWebViewController:(QCustomChooseWebViewController*)segue.destinationViewController];
        [self.qWebViewController setDelegate:self];
        [self loadUrl:self.startUrl];
    }
}

-(void) loadUrl:(NSString*) url {
    [self setCurrentUrl:url];
    [self.qWebViewController loadUrl:url];
    [self.qWebViewController setInjectedJavascriptCode:self.injectedJavascriptCode];
}

-(void) closeAction {
    if(self.delegate != nil) {
        [self.delegate cancelChooseLink:self.callbackId];
    }
    [self closeVC];
}

-(void) chooseLink:(NSString*) url {
    if(self.delegate != nil) {
        [self.delegate chooseLink:url withCallback:self.callbackId];
    }
    [self closeVC];
}

-(void) contentChanged:(NSString*) html {
    if(self.delegate != nil) {
        [self.delegate contentChanged:html withCallback:self.callbackId];
    }
}

-(void) closeVC {
    self.delegate = nil;
    [self.qWebViewController setDelegate:nil];
    self.qWebViewController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
#if __has_feature(objc_arc)
    
#else
    [self.qWebViewController release];
    [super dealloc];
#endif
}

@end
