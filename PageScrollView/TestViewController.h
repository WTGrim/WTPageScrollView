//
//  TestViewController.h
//  PageScrollView
//
//  Created by Dwt on 2017/2/7.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollViewDelegate.h"

@interface TestViewController : UIViewController<ScrollPageViewChildVcDelegate>

@property(nonatomic, strong)NSMutableArray *dataArray;


@end
