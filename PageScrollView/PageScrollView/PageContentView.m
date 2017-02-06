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
@property(nonatomic, strong)UICollectionViewFlowLayout *collectionLayout;
@property(nonatomic, weak)UIViewController *parentViewController;
@property(nonatomic, assign)NSInteger itemsCount;
@property(nonatomic, strong)NSMutableDictionary<NSString *, UIViewController<ScrollPageViewChildVcDelegate> *> *childVcDict; //所有子控制器
@property(nonatomic, strong)UIViewController<ScrollPageViewChildVcDelegate> *currentChildVc;

@property(nonatomic, assign)BOOL changeAnimated;
@property(nonatomic, assign)NSInteger oldIndex;
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, assign)BOOL forbidTouchToChangePosition;

@end

static NSString *const cellID = @"cellID";

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
    _forbidTouchToChangePosition = NO;
    _systemVersion = [[[UIDevice currentDevice]systemVersion] integerValue];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfChildViewControllers)]) {
        self.itemsCount = [self.delegate numberOfChildViewControllers];
    }
    [self addSubview:self.collectionView];
    
    //左滑pop和普通左滑的处理
    UINavigationController *nav = (UINavigationController *)self.parentViewController.parentViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        if (nav.childViewControllers.count == 1) return;
        if (nav.interactivePopGestureRecognizer) {
            
            __weak typeof(self)weakSelf = self;
           [_collectionView setScrollViewShouldBeginPanGestureRecognizer:^BOOL(WTCollectionView *collectionView, UIPanGestureRecognizer *panGestureRecognizer) {
               CGFloat translationX = [panGestureRecognizer translationInView:panGestureRecognizer.view].x;
               
               if (collectionView.contentOffset.x == 0 && translationX > 0) {
                   nav.interactivePopGestureRecognizer.enabled = true;
               }else{
                   nav.interactivePopGestureRecognizer.enabled = false;
               }
               
               if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(scrollPageController:contentScrollView:shouldBeginPanGesture:)]) {
                   return [weakSelf.delegate scrollPageController:weakSelf.parentViewController contentScrollView:collectionView shouldBeginPanGesture:panGestureRecognizer];
               }else{
                   return YES;
               }
           }];
        }
    }

}

- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(memoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
}

- (void)memoryWarningNotification:(NSNotification *)notification{
    
    __weak typeof(self)weakSelf = self;
    [_childVcDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<ScrollPageViewChildVcDelegate> * _Nonnull obj, BOOL * _Nonnull stop) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            if (obj != strongSelf.currentChildVc) {
                [_childVcDict removeObjectForKey:key];
                [PageContentView removeChildVc:obj];
            }
        }
        
    }];
}

+ (void)removeChildVc:(UIViewController *)viewController{
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.currentChildVc) {
        self.currentChildVc.view.frame = self.bounds;
    }
}

- (void)dealloc{
    self.parentViewController = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 外界设置偏移量
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated{
    
    _forbidTouchToChangePosition = YES;
    NSInteger currentIndex = offset.x / self.collectionView.bounds.size.width;
    _oldIndex = _currentIndex;
    self.currentIndex = currentIndex;
    _changeAnimated = YES;
    
    if (animated) {
        CGFloat deltaX = offset.x - self.collectionView.contentOffset.x;
        NSInteger page = fabs(deltaX) / self.collectionView.bounds.size.width;
        //滑动两页以上省去中间动画
        if (page >= 2) {
            _changeAnimated = NO;
            __weak typeof(self)weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf.collectionView setContentOffset:offset animated:NO];
                }
            });
        }else{
            [self.collectionView setContentOffset:offset animated:animated];
        }
    }else{
        [self.collectionView setContentOffset:offset animated:animated];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.forbidTouchToChangePosition || self.collectionView.contentOffset.x <= 0 || self.collectionView.contentOffset.x > self.collectionView.contentSize.width - self.collectionView.bounds.size.width) {
        return;
    }
    
    CGFloat tempProgress = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    CGFloat progress = tempProgress - floor(tempProgress);
    NSInteger index = tempProgress;
    CGFloat deltaX = self.collectionView.contentOffset.x - _oldOffset;
    //向右滑动
    if (deltaX > 0) {
        if (progress == 0.0) {
            return;
        }
        self.currentIndex = index + 1;
        self.oldIndex = index;
    }else if (deltaX < 0) {//向左滑动
        
        progress = 1.0 - progress;
        self.currentIndex = index;
        self.oldIndex = index + 1;
        
    }else{
        return;
    }
    
    [self didMoveFromIndex:self.oldIndex toIndex:self.currentIndex progress:progress];
}

//滚动减速完成更新title
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

- (void)didMoveFromIndex:(NSInteger)oldIndex toIndex:(NSInteger)currentIndex progress:(CGFloat)progress{
    
    if (self.segmentView) {
        [self.segmentView adjustUIWithProgress:progress oldIndex:oldIndex currentIndex:currentIndex];
    }
}

- (WTCollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[WTCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.collectionLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = true;
        _collectionView.scrollsToTop = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionLayout{
    
    if (!_collectionLayout) {
        _collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionLayout.itemSize = self.bounds.size;
        _collectionLayout.minimumLineSpacing = 0.0;
        _collectionLayout.minimumInteritemSpacing = 0.0;
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionLayout;
}


@end
