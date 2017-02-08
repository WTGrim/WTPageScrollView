//
//  PageContentView.m
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PageContentView.h"
#import "UIViewController+PageController.h"

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
@property(nonatomic, assign)BOOL needManageLifeCycle;

@end

static NSString *const cellID = @"cellID";

@implementation PageContentView

- (instancetype)initWithFrame:(CGRect)frame segmentView:(SegmentScrollView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<ScrollPageViewDelegate>)delegate{
    
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.segmentView = segmentView;
        self.parentViewController = parentViewController;
        _needManageLifeCycle = ![parentViewController shouldAutomaticallyForwardAppearanceMethods];
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
    
    self.forbidTouchToChangePosition = YES;
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


#pragma mark - collectionViewDelegate And collectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    //避免重用时显示错误， 移除subViews
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_systemVersion >= 8) {
        [self setChildVcCell:cell indexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //没有滚动完成
    if (_currentIndex == indexPath.row) {
        
        if (_needManageLifeCycle) {
            UIViewController<ScrollPageViewChildVcDelegate> *currentVc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", _currentIndex]];
            [currentVc beginAppearanceTransition:YES animated:NO];
            UIViewController<ScrollPageViewChildVcDelegate> *oldVc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            [oldVc beginAppearanceTransition:NO animated:NO];
        }
        
        [self didAppearAtIndex:_currentIndex];
        [self didDisappearAtIndex:indexPath.row];
    }else{
        
        if (_oldIndex == indexPath.row) {//滚动完成
            if (self.forbidTouchToChangePosition && !_changeAnimated) {
                [self willDisappearAtIndex:_oldIndex];
                [self didDisappearAtIndex:_oldIndex];
                
            }else{
                
                [self didAppearAtIndex:_currentIndex];
                [self didDisappearAtIndex:indexPath.row];
            }
        }else{
            
            //滚动还没有完成又反向打开另一页
            if (_needManageLifeCycle) {
                
                UIViewController<ScrollPageViewChildVcDelegate> *currentVc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", _oldIndex]];
                [currentVc beginAppearanceTransition:YES animated:NO];
                UIViewController<ScrollPageViewChildVcDelegate> *oldVc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                [oldVc beginAppearanceTransition:NO animated:NO];
            }
            [self didAppearAtIndex:_oldIndex];
            [self didDisappearAtIndex:indexPath.row];
        }
        
    }
}

- (void)setChildVcCell:(UICollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    _currentChildVc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    BOOL isFirstLoad = _currentChildVc == nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(childViewController:forIndex:)]) {
        
        if (!_currentChildVc) {
            _currentChildVc = [_delegate childViewController:nil forIndex:indexPath.row];
            
            _currentChildVc.currentIndex = indexPath.row;
            [self.childVcDict setValue:_currentChildVc forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        }else{
            [_delegate childViewController:_currentChildVc forIndex:indexPath.row];
        }
    }
    
    if (_currentChildVc.pageController != self.parentViewController) {
        [self.parentViewController addChildViewController:_currentChildVc];
    }
    
    _currentChildVc.view.frame = self.bounds;
    [cell.contentView addSubview:_currentChildVc.view];
    [_currentChildVc didMoveToParentViewController:self.parentViewController];
    
    if (_isLoadFirstView) {
        if (self.forbidTouchToChangePosition && !_changeAnimated) {
            [self willAppearAtIndex:_currentIndex];
            
            if (isFirstLoad) {
                if ([_currentChildVc respondsToSelector:@selector(wt_viewDidLoadForIndex:)]) {
                    [_currentChildVc wt_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self didAppearAtIndex:_currentIndex];
        }else{
            
            [self willAppearAtIndex:indexPath.row];
            if (isFirstLoad) {
                if ([_currentChildVc respondsToSelector:@selector(wt_viewDidLoadForIndex:)]) {
                    [_currentChildVc wt_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self didAppearAtIndex:indexPath.row];
        }
        _isLoadFirstView = NO;
        
    }else{
        
        if (self.forbidTouchToChangePosition && !_changeAnimated) {
            [self willAppearAtIndex:_currentIndex];
            if (isFirstLoad) {
                if ([_currentChildVc respondsToSelector:@selector(wt_viewDidLoadForIndex:)]) {
                    [_currentChildVc wt_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self didAppearAtIndex:_currentIndex];
        }else{
            
            [self willAppearAtIndex:indexPath.row];
            if (isFirstLoad) {
                if ([_currentChildVc respondsToSelector:@selector(wt_viewDidLoadForIndex:)]) {
                    [_currentChildVc wt_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self willDisappearAtIndex:_oldIndex];
        }
    }
    
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.forbidTouchToChangePosition || scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
        return;
    }
    
    CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
    CGFloat progress = tempProgress - floor(tempProgress);
    NSInteger index = tempProgress;
    CGFloat deltaX = scrollView.contentOffset.x - _oldOffset;
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
    
    NSInteger currentIndex = scrollView.contentOffset.x / self.bounds.size.width;
    
    [self didMoveFromIndex:currentIndex toIndex:currentIndex progress:1.0];
    [self adjustSegmentTitleToCurrentIndex:currentIndex];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    _oldOffset = scrollView.contentOffset.x;
    self.forbidTouchToChangePosition = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    UINavigationController *nav = (UINavigationController *)self.parentViewController.parentViewController;
    if ([nav isKindOfClass:[UINavigationController class]] && nav.interactivePopGestureRecognizer) {
        nav.interactivePopGestureRecognizer.enabled = true;
    }
}

- (void)willAppearAtIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *vc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (vc) {
        if ([vc respondsToSelector:@selector(wt_viewWillAppearForIndex:)]) {
            [vc wt_viewWillAppearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [vc beginAppearanceTransition:true animated:false];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewControllWillAppear:forIndex:)]) {
            [_delegate scrollPageController:self.parentViewController childViewControllWillAppear:vc forIndex:index];
        }
    }
}

- (void)didAppearAtIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *vc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (vc) {
        if ([vc respondsToSelector:@selector(wt_viewDidAppearForIndex:)]) {
            [vc wt_viewDidAppearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [vc endAppearanceTransition];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewControllDidAppear:forIndex:)]) {
            [_delegate scrollPageController:self.parentViewController childViewControllDidAppear:vc forIndex:index];
        }
    }
}

- (void)willDisappearAtIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *vc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (vc) {
        if ([vc respondsToSelector:@selector(wt_viewWillDisappearForIndex:)]) {
            [vc wt_viewWillDisappearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [vc beginAppearanceTransition:false animated:false];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewControllWillDisappear:forIndex:)]) {
            [_delegate scrollPageController:self.parentViewController childViewControllWillDisappear:vc forIndex:index];
        }
    }
}

- (void)didDisappearAtIndex:(NSInteger)index{
    
    UIViewController<ScrollPageViewChildVcDelegate> *vc = [self.childVcDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (vc) {
        if ([vc respondsToSelector:@selector(wt_viewDidDisappearForIndex:)]) {
            [vc wt_viewDidDisappearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [vc endAppearanceTransition];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewControllDidDisappear:forIndex:)]) {
            [_delegate scrollPageController:self.parentViewController childViewControllDidDisappear:vc forIndex:index];
        }
    }
}

- (void)adjustSegmentTitleToCurrentIndex:(NSInteger)currentIndex{
    
    if (self.segmentView) {
        [self.segmentView adjustTitleOffsetToCurrentIndex:currentIndex];
    }
}

- (void)didMoveFromIndex:(NSInteger)oldIndex toIndex:(NSInteger)currentIndex progress:(CGFloat)progress{
    
    if (self.segmentView) {
        [self.segmentView adjustUIWithProgress:progress oldIndex:oldIndex currentIndex:currentIndex];
    }
}

- (WTCollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[WTCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.collectionLayout];
        //背景颜色
        _collectionView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
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

- (NSMutableDictionary<NSString *,UIViewController<ScrollPageViewChildVcDelegate> *> *)childVcDict{
    
    if (!_childVcDict) {
        _childVcDict = [NSMutableDictionary dictionary];
    }
    return _childVcDict;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        
        if (self.segmentView.titleStyle.isAdjustTitleBeginDrag) {
            [self adjustSegmentTitleToCurrentIndex:currentIndex];
        }
    }
    
}

//外界刷新视图
- (void)reload{
    
    [self.childVcDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<ScrollPageViewChildVcDelegate> * _Nonnull obj, BOOL * _Nonnull stop) {
       
        [PageContentView removeChildVc:obj];
        obj = nil;
    }];
    
    self.childVcDict = nil;
    [self.collectionView reloadData];
    [self commonConfig];
}

@end
