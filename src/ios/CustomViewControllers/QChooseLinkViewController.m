//
//  ChooseLinkViewController.m
//  Groups
//
//  Created by Home on 2/5/17.
//
//

#import "QChooseLinkViewController.h"
#import "Q.h"

@interface QChooseLinkViewController ()

@end

@implementation QChooseLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.urlEditText setText:self.initUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
}

- (void)dealloc {
    [_urlEditText release];
    [_chooseBtn release];
    [super dealloc];
}
- (IBAction)closeAction:(id)sender {
    [super closeAction];
}

- (IBAction)chooseAction:(id)sender {
    [super chooseLink:self.currentUrl];
    
}
- (IBAction)urlBeginEdit:(id)sender {
    [self.chooseBtn setEnabled:NO];
}

- (IBAction)urlEndEdit:(id)sender {
    [self.chooseBtn setEnabled:YES];
    if(![self.urlEditText.text isEqualToString:[super currentUrl]])
        [super loadUrl:self.urlEditText.text];
}
@end
