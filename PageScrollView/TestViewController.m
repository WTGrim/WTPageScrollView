//
//  TestViewController.m
//  PageScrollView
//
//  Created by Dwt on 2017/2/7.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "TestViewController.h"
#import "UIViewController+PageController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)wt_viewDidLoadForIndex:(NSInteger)index {
    //    NSLog(@"%@",self.view);
    //    NSLog(@"%@", self.zj_scrollViewController);
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    testBtn.backgroundColor = [UIColor whiteColor];
    [testBtn setTitle:@"点击" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(testBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testBtn];
    
    self.pageController.title  = @"测试";
    
    if (index % 2==0) {
        self.view.backgroundColor = [UIColor purpleColor];
    } else {
        self.view.backgroundColor = [UIColor greenColor];
        
    }
}

- (void)testBtnOnClick:(UIButton *)btn{
    NSLog(@"点击了按钮");
}

// 使用系统的生命周期方法
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear------%ld", self.currentIndex);
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear-----%ld", self.currentIndex);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear-----%ld", self.currentIndex);
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear--------%ld", self.currentIndex);
    
}

// 使用ZJScrollPageViewChildVcDelegate提供的生命周期方法

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"viewDidDisappear--------");
//
//}
//- (void)zj_viewWillAppearForIndex:(NSInteger)index {
//    NSLog(@"viewWillAppear------");
//
//}
//
//
//- (void)zj_viewDidAppearForIndex:(NSInteger)index {
//    NSLog(@"viewDidAppear-----");
//
//}
//
//
//- (void)zj_viewWillDisappearForIndex:(NSInteger)index {
//    NSLog(@"viewWillDisappear-----");
//
//}
//
//- (void)zj_viewDidDisappearForIndex:(NSInteger)index {
//    NSLog(@"viewDidDisappear--------");
//
//}


- (void)dealloc
{
    //    NSLog(@"%@-----test---销毁", self.description);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
