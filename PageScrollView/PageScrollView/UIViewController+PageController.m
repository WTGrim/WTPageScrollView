//
//  UIViewController+PageController.m
//  PageScrollView
//
//  Created by Dwt on 2017/2/6.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "UIViewController+PageController.h"
#import <objc/runtime.h>
#import "PageScrollViewDelegate.h"

@implementation UIViewController (PageController)


- (UIViewController *)pageController{
    
    UIViewController *vc = self;
    while (vc) {
        if ([vc conformsToProtocol:@protocol(ScrollPageViewDelegate)]) {
            break;
        }
        vc = vc.parentViewController;
    }
    return vc;
}


- (void)setCurrentIndex:(NSInteger)currentIndex{
    objc_setAssociatedObject(self, @selector(currentIndex), [NSNumber numberWithInteger:currentIndex], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)currentIndex{
    
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
