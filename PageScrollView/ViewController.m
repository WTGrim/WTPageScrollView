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
#import "Test2ViewController.h"

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
    
    //segment不滚动，平分宽度
//    style.scrollTitle = false;
    //适应宽度
    style.sliderWidthFitTitle = true;

    //附加按钮
    style.showExtraButton = true;
    style.extraButtonImageName = @"extraBtn.png";
    
    self.titles = @[@"精选",
                    @"朝闻天下",
                    @"新闻30分",
                    @"体育",
                    @"娱乐",
                    @"旅游频道",
                    @"精彩视频",
                    @"综艺",
                    @"热话题",
                    ];
    
    PageScrollView *pageView = [[PageScrollView alloc]initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) titleStyle:style titles:self.titles parentViewController:self delegate:self];
    pageView.extraBtnClick = ^(UIButton *btn){
        NSLog(@"点击了附加按钮");
    };
    [self.view addSubview:pageView];
    
}

- (NSInteger)numberOfChildViewControllers{
    return self.titles.count;
}

- (UIViewController<ScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    if (!childVc) {
        if (index % 2 == 0) {
            childVc = [[TestViewController alloc]init];
            childVc.view.backgroundColor = [UIColor purpleColor];
        }else{
            childVc = [[Test2ViewController alloc]init];
            childVc.view.backgroundColor = [UIColor whiteColor];
        }
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
