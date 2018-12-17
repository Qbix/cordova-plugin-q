//
//  MultiTestChooserViewController.m
//  Shipping
//
//  Created by Home on 3/29/16.
//
//

#import "MultiTestChooserViewController.h"
#import "AppDelegate.h"
#import "Q.h"

@interface MultiTestChooserViewController ()

@end

@implementation MultiTestChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputTextField.delegate = self;
    [super setDelegate:self];
    if(self.launchUrl != nil) {
        [self load:self.launchUrl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField {
    [self.view endEditing:YES];
    
    [self load:textField.text];
    
    return YES;
}

-(void) load:(NSString*) inputText {
    if([inputText isEqualToString:@"local"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"index.html"]];
        [self loadQCordovaApp:url.description];
    } else {
        NSURL *url = [super getNSURLFromString:inputText];
        if(url) {
            [self loadQCordovaApp:url.description];
        } else {
            NSString* project = [inputText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            [self loadQCordovaApp:[NSString stringWithFormat:@"http://qbixstaging.com/%@", project]];
        }
    }
}

-(void) loadQCordovaApp:(NSString*) url {
    QWebViewController* qWebViewController = [[QWebViewController alloc] initWithUrl:url andParameters:[[Q getInstance] getAdditionalParamsForUrl]];
    
    AppDelegate *delegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    delegate.viewController = qWebViewController;
    delegate.window.rootViewController =delegate.viewController;
    [delegate.window reloadInputViews];
    
    [super addNewBookmark:url];
}

@end
