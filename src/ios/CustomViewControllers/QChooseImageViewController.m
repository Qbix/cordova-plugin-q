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
//@property(nonatomic, strong) QWebViewController *qWebViewController;
@end

@implementation QChooseImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClipboard:) name:UIPasteboardChangedNotification object:nil];
    
    //customize choose image hint view
    if([self navigationBarBackgroundColor] != nil) {
        [self.navigationController.navigationBar setBarTintColor:[self navigationBarBackgroundColor]];
    }
    if([self navigationBarButtonsColor] != nil) {
        [self.navigationItem.leftBarButtonItem setTintColor:[self navigationBarButtonsColor]];
    }
}

- (CGRect)frameForView:(UIView *)view {
    return [view convertRect:view.bounds toView:nil];;
}

-(CABasicAnimation*) getPulseAnimation {
    CABasicAnimation *pulseAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration=1.0;
    pulseAnimation.repeatCount=HUGE_VALF;
    pulseAnimation.autoreverses=YES;
    pulseAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue=[NSNumber numberWithFloat:0.5];
    return pulseAnimation;
}

-(void) viewDidAppear:(BOOL)animated {
    CGRect navigationBarRect = [self.navigationController.navigationBar frame];
    CGRect cancelBtnRect = [self frameForView:[self.navigationItem.leftBarButtonItem valueForKey:@"view"]];
    
    CGFloat labelWidth = navigationBarRect.size.width - 2*navigationBarRect.origin.x - 2*(2*cancelBtnRect.origin.x + cancelBtnRect.size.width);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    label.font = [UIFont boldSystemFontOfSize: 14.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.navigationItem.leftBarButtonItem.tintColor;
    label.text = @"Choose an Image\nby tapping on it";
    [label.layer addAnimation:[self getPulseAnimation] forKey:@"animateOpacity"];
    
    self.navigationItem.titleView = label;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self setInjectedJavascriptCode:@"(function() {setInterval(function() {var top = 0;var imgs = document.getElementsByTagName('img');for (var i = 0, l = imgs.length; i < l; ++i) {var img = imgs[i];var found = null;var p = img;while (p = p.parentNode) {if (p.tagName && p.tagName.toUpperCase() === 'A') {found = p;break;}}if (found) {continue;}if (!img._addedEventHandlers) {img._addedEventHandlers = true;img.addEventListener('touchstart', _handleTouchStart);img.addEventListener('touchend', _handleTouchEnd);}function _handleTouchStart(e) {top = document.body.scrollTop;}function _handleTouchEnd(e) {if (Math.abs(top - document.body.scrollTop) > 10) return;var src = e.target.getAttribute('src');console.log(src);Q.Cordova.chooseImageEvent(src, null, null)}}}, 300);})();"];
    
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
