//
//  UIViewController+PageController.h
//  PageScrollView
//
//  Created by Dwt on 2017/2/6.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PageController)

@property(nonatomic, weak, readonly)UIViewController *pageController;
@property(nonatomic, assign)NSInteger currentIndex;

@end
