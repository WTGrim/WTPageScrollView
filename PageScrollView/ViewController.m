//
//  ViewController.m
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "ViewController.h"
#import "PageScrollView.h"
#import "TestViewController.h"

@interface ViewController ()<ScrollPageViewDelegate>
@property(nonatomic, strong)NSArray *titles;
@property(nonatomic, strong)NSArray *childVcs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    PageTitleStyle *style = [[PageTitleStyle alloc]init];
    style.showSlider = true;
    style.scaleTitle = true;
    style.changeTitleColor = true;
//    style.sliderWidthFitTitle = true;
    self.titles = @[@"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑",
                    @"视频",
                    @"无厘头",
                    @"美女图片",
                    @"今日房价",
                    @"头像",
                    ];
    
    PageScrollView *pageView = [[PageScrollView alloc]initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) titleStyle:style titles:self.titles parentViewController:self delegate:self];
    [self.view addSubview:pageView];
    
}

- (NSInteger)numberOfChildViewControllers{
    return self.titles.count;
}

- (UIViewController<ScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    if (!childVc) {
        childVc = [[TestViewController alloc]init];
    }
    return childVc;
}


- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
