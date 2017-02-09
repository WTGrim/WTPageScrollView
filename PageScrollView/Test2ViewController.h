//
//  Test2ViewController.h
//  PageScrollView
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollViewDelegate.h"

@interface Test2ViewController : UIViewController<ScrollPageViewChildVcDelegate>

@property(nonatomic, strong)NSArray *dataArray;

@end
