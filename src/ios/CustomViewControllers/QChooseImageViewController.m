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
    
    //customize choose image hint view
    [self.bottomImageSelectHint setBackgroundColor:[self.navigationController.navigationBar barTintColor]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self setInjectedJavascriptCode:@"(function () {setInterval(function () {var imgs = document.getElementsByTagName('img');for (var i=0, l=imgs.length; i<l; ++i) {var img = imgs[i];var found = null;var p = img; if(p.src != undefined) { while (p = p.parentNode) {if (p.tagName && p.tagName.toUpperCase() === 'A') {found = p;break;}}} else {found = p;}if (found) {continue;}img.removeEventListener('click', _handleTouchStart);img.addEventListener('click', _handleTouchStart);}function _handleTouchStart(e) {var src = e.target.getAttribute('src');console.log(src); Q.Cordova.chooseImageEvent(src, null, null);}}, 300);})();"];
    [super prepareForSegue:segue sender:sender];
}


-(void) copyToClipboard:(NSNotification*) notification {
    UIPasteboard* clipboard = (UIPasteboard*)notification.object;
    if(clipboard != nil && clipboard.string != nil) {
        [super chooseLink:clipboard.string];
    }
}
    
-(void) chooseImage:(NSString*) image {
    [super chooseLink:image];
}

//- (void)dealloc {
//    [super dealloc];
//}
- (IBAction)cancelAction:(id)sender {
    [super closeAction];
}
@end
