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
    [self.urlEditText setText:self.startUrl];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self setInjectedJavascriptCode:@"(function () {_updateUrl(); for (var k in window.history) {if (typeof window.history[k]  === 'function') {var a = window.history[k];window.history[k] = function () { var r = a.apply(this, arguments); _updateUrl(); return r; }}}function _updateUrl() {Q.Cordova.changeInnerUrlEvent(location.href, null, null);}})();"];
    [super prepareForSegue:segue sender:sender];
}

//- (void)dealloc {
//    [_urlEditText release];
//    [_chooseBtn release];
//    [super dealloc];
//}
- (IBAction)closeAction:(id)sender {
    [super closeAction];
}

- (IBAction)chooseAction:(id)sender {
    [super chooseLink:self.urlEditText.text];
    
}
- (IBAction)urlBeginEdit:(id)sender {
    [self.chooseBtn setEnabled:NO];
}

- (IBAction)urlEndEdit:(id)sender {
    [self.chooseBtn setEnabled:YES];
    if(![self.urlEditText.text isEqualToString:[super currentUrl]])
        [super loadUrl:self.urlEditText.text];
}

-(void) changeUrl:(NSString*) newUrl {
    [self.urlEditText setText:newUrl];
}
    
@end
