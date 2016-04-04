//
//  MultiTestChooserViewController.m
//  Shipping
//
//  Created by Home on 3/29/16.
//
//

#import "MultiTestChooserViewController.h"

@interface MultiTestChooserViewController () 

@end

@implementation MultiTestChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputTextField.delegate = self;
    [super setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField {
    [self.view endEditing:YES];
    
    NSURL *url = [super getNSURLFromString:textField.text];
    if(url) {
        [self loadQCordovaApp:url.description];
    } else {
        NSString* project = [textField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [self loadQCordovaApp:[NSString stringWithFormat:@"http://qbixstaging.com/%@", project]];
    }
    
    return YES;
}

-(void) loadQCordovaApp:(NSString*) url {
    QWebViewController* qWebViewController = [[QWebViewController alloc] initWithUrl:url andParameters:[[Q getInstance] getAdditionalParamsForUrl]];
    
    [self presentViewController:qWebViewController animated:YES completion:nil];
    
    [super addNewBookmark:url];
}

@end
