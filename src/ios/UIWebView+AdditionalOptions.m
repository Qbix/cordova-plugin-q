//
//  UIWebView+AdditionalOptions.m
//  Yang2020
//
//  Created by adventis on 7/22/19.
//

#import "UIWebView+AdditionalOptions.h"

@implementation UIWebView (AdditionalOptions)

static bool isEnableContextMenu = true;

+ (void)setSelectMenuShown:(BOOL)isEnable {
    isEnableContextMenu = isEnable;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL superCanPerform = [super canPerformAction:action withSender:sender];
    if (superCanPerform && !isEnableContextMenu) {
        if (action == @selector(copy:) ||
            action == @selector(paste:)||
            action == @selector(cut:)||
            action == @selector(select:)||
            action == @selector(selectAll:)||
            action == @selector(_share:))
        {
            return false;
        }
    }
    return superCanPerform;
}

@end
