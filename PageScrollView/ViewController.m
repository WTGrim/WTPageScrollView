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
@property(nonatomic, strong)NSArray<UIViewController<ScrollPageViewChildVcDelegate> *> *childVcs;

@property (weak, nonatomic) SegmentScrollView *segmentView;
@property (weak, nonatomic) PageContentView *contentView;
@end

@implementation ViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.automaticallyAdjustsScrollViewInsets = false;
//    PageTitleStyle *style = [[PageTitleStyle alloc]init];
//    style.showSlider = true;
//    style.scaleTitle = true;
//    style.changeTitleColor = true;
//    
//    //segment不滚动，平分宽度
////    style.scrollTitle = false;
//    //适应宽度
//    style.sliderWidthFitTitle = true;
//
//    //附加按钮
//    style.showExtraButton = true;
//    style.extraButtonImageName = @"extraBtn.png";
//    
//    self.titles = @[@"精选",
//                    @"朝闻天下",
//                    @"新闻30分",
//                    @"体育",
//                    @"娱乐",
//                    @"旅游频道",
//                    @"精彩视频",
//                    @"综艺",
//                    @"热话题",
//                    ];
//    
//    PageScrollView *pageView = [[PageScrollView alloc]initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) titleStyle:style titles:self.titles parentViewController:self delegate:self];
//    pageView.extraBtnClick = ^(UIButton *btn){
//        NSLog(@"点击了附加按钮");
//    };
//    [self.view addSubview:pageView];
//    
//}
//
//- (NSInteger)numberOfChildViewControllers{
//    return self.titles.count;
//}
//
//- (UIViewController<ScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index{
//    
//    UIViewController<ScrollPageViewChildVcDelegate> *childVc = reuseViewController;
//    if (!childVc) {
//        if (index % 2 == 0) {
//            childVc = [[TestViewController alloc]init];
//            childVc.view.backgroundColor = [UIColor purpleColor];
//        }else{
//            childVc = [[Test2ViewController alloc]init];
//            childVc.view.backgroundColor = [UIColor whiteColor];
//        }
//    }
//    return childVc;
//}
//
//
//- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
//    return NO;
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"效果示例";
    
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.childVcs = [self setupChildVc];
    // 初始化
    [self setupSegmentView];
    [self setupContentView];
    
}

- (void)setupSegmentView {
    PageTitleStyle *style = [[PageTitleStyle alloc] init];
    style.showCover = YES;
    // 不要滚动标题, 每个标题将平分宽度
    style.scrollTitle = NO;
    
    // 渐变
    style.changeTitleColor = YES;
    // 遮盖背景颜色
    style.coverBackgroundColor = [UIColor whiteColor];
    //标题一般状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.normalTitleColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    //标题选中状态颜色 --- 注意一定要使用RGB空间的颜色值
    style.selectedTitleColor = [UIColor colorWithRed:235.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    self.titles = @[@"国内新闻", @"新闻头条"];
    
    // 注意: 一定要避免循环引用!!
    __weak typeof(self) weakSelf = self;
    SegmentScrollView *segment = [[SegmentScrollView alloc]initWithFrame:CGRectMake(0, 64.0, 160.0, 28.0) titleStyle:style delegate:self titlesArray:self.titles titleDidClick:^(TitleView *titleView, NSInteger index) {
        [weakSelf.contentView setContentOffset:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
    }];

    // 自定义标题的样式
    segment.layer.cornerRadius = 14.0;
    segment.backgroundColor = [UIColor redColor];
    // 当然推荐直接设置背景图片的方式
    //    segment.backgroundImage = [UIImage imageNamed:@"extraBtnBackgroundImage"];
    
    self.segmentView = segment;
    self.navigationItem.titleView = self.segmentView;
    
}

- (void)setupContentView {
    
    PageContentView *content = [[PageContentView alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) segmentView:self.segmentView parentViewController:self delegate:self];
    self.contentView = content;
    [self.view addSubview:self.contentView];
    
}

- (NSArray *)setupChildVc {
    
    TestViewController *vc1 = [TestViewController new];
    vc1.view.backgroundColor = [UIColor redColor];
    
    Test2ViewController *vc2 = [Test2ViewController new];
    vc2.view.backgroundColor = [UIColor greenColor];
    
    NSArray *childVcs = [NSArray arrayWithObjects:vc2, vc1, nil];
    return childVcs;
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}




- (UIViewController<ScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<ScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        childVc = self.childVcs[index];
    }
    
    return childVc;
}


-(CGRect)frameOfChildControllerForContainer:(UIView *)containerView {
    return  CGRectInset(containerView.bounds, 20, 20);
}


@end
