//
//  PageContentView.m
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PageContentView.h"

@interface PageContentView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>{
    
    CGFloat _oldOffset;
    NSInteger _systemVersion;
    BOOL _isLoadFirstView;
}

@property(nonatomic, weak)SegmentScrollView *segmentView;
@property(nonatomic, strong)WTCollectionView *collectionView;
@property(nonatomic, strong)UICollectionViewLayout *layout;
@property(nonatomic, weak)UIViewController *parentViewController;
@property(nonatomic, assign)NSInteger itemsCount;
@property(nonatomic, strong)NSMutableDictionary<NSString *, UIViewController<ScrollPageViewChildVcDelegate> *> *childVcDict; //所有子控制器
@property(nonatomic, strong)UIViewController<ScrollPageViewChildVcDelegate> *currentChildVc;

@property(nonatomic, assign)BOOL changeAnimated;
@property(nonatomic, assign)NSInteger oldIndex;
@property(nonatomic, assign)NSInteger currentIndex;

@end

@implementation PageContentView

- (instancetype)initWithFrame:(CGRect)frame segmentView:(SegmentScrollView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<ScrollPageViewDelegate>)delegate{
    
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.segmentView = segmentView;
        self.parentViewController = parentViewController;
        
        [self commonConfig];
        [self addNotification];
    }
    return self;
}

- (void)commonConfig{
    
    _oldIndex = -1;
    _currentIndex = 0;
    _oldOffset = 0.0;
    _isLoadFirstView = YES;
    _systemVersion = [[[UIDevice currentDevice]systemVersion] integerValue];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfChildViewControllers)]) {
        self.itemsCount = [self.delegate numberOfChildViewControllers];
    }
    [self addSubview:self.collectionView];
    
    //左滑pop和普通左滑的处理
    UINavigationController *nav = (UINavigationController *)self.parentViewController.parentViewController;
    
}

- (void)addNotification{
    
}
@end
