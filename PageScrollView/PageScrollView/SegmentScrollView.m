//
//  SegmentScrollView.m
//  PageScrollView
//
//  Created by Dwt on 2017/2/4.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "SegmentScrollView.h"

@interface SegmentScrollView ()<UIScrollViewDelegate>{
    
    NSUInteger _oldIndex;
    NSUInteger _currentIndex;
    CGFloat _currentWidth;
}
//滑动条
@property(nonatomic, strong)UIView *sliderView;
//遮盖
@property(nonatomic, strong)UIView *coverLayer;

//滚动的ScrollView
@property(nonatomic, strong)UIScrollView *scrollView;
//背景
@property(nonatomic, strong)UIImageView *backgroundImageView;
//附加按钮
@property(nonatomic, strong)UIButton *extraButton;

//设置渐变颜色
@property(nonatomic, strong)NSArray *deltaRGBArray;
@property(nonatomic, strong)NSArray *selectedColorArray;
@property(nonatomic, strong)NSArray *normalColorArray;

@property(nonatomic, strong)NSMutableArray *titleViews;
@property(nonatomic, strong)NSMutableArray *titleWidths;
@property(nonatomic, copy)TitleDidClick titleDidClick;

@end

static CGFloat const Gapx  = 5.0;
static CGFloat const GapWidth = 2 * Gapx;
static CGFloat const contentOffsetX = 20.0;

@implementation SegmentScrollView

- (NSMutableArray *)titleViews{
    if (!_titleViews) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

- (NSMutableArray *)titleWidths{
    if (!_titleWidths) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}



- (instancetype)initWithFrame:(CGRect)frame titleStyle:(PageTitleStyle *)titleStyle delegate:(id<ScrollPageViewDelegate>)delegate titlesArray:(NSArray *)titlesArray titleDidClick:(TitleDidClick)titleDidClick{
    
    if (self = [super initWithFrame:frame]) {
        self.titleStyle = titleStyle;
        self.delegate = delegate;
        self.titlesArray = titlesArray;
        self.titleDidClick = titleDidClick;
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        if (!self.titleStyle.isScrollTitle) {
            self.titleStyle.scaleTitle = !(self.titleStyle.isShowSlider || self.titleStyle.isShowCover);  //放大标题和滑条不同时使用
        }
        
        [self initSubviews];
        [self setupUI];
    }
    return self;
}


- (void)initSubviews{
    
    [self addSubview:self.scrollView];
    
    if (self.titleStyle.isShowSlider) {
        [self.scrollView addSubview:self.sliderView];
    }
    
    if (self.titleStyle.isShowCover) {
        [self.scrollView insertSubview:self.coverLayer atIndex:0];
    }
    
    if (self.titleStyle.isShowExtraButton) {
        [self addSubview:self.extraButton];
    }
    
    [self setTitles];
}

#pragma mark - 设置titleView
- (void)setTitles{
    
    if(self.titlesArray.count == 0)return;
    NSInteger index = 0;
    for (NSString *title in self.titlesArray) {
        TitleView *titleView = [[TitleView alloc]initWithFrame:CGRectZero];
        titleView.tag = index;
        
        titleView.titleFont = self.titleStyle.titleFont;
        titleView.textColor = self.titleStyle.normalTitleColor;
        titleView.text = title;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setUpTitleView:forIndex:)]) {
            [self.delegate setUpTitleView:titleView forIndex:index];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleOnClick:)];
        [titleView addGestureRecognizer:tap];
        
        CGFloat titleViewWidth = [titleView  titleViewWidth];
        [self.titleWidths addObject:@(titleViewWidth)];
        [self.titleViews addObject:titleView];
        [self.scrollView addSubview:titleView];
        index++;
    }
}

- (void)setupUI{
    
    if (self.titlesArray.count == 0 ) return;
    [self setupScrollView];
    [self setupTitleView];
    [self setupSlider];
    
    //设置滚动
    if (self.titleStyle.isScrollTitle) {
        TitleView *titleView = (TitleView *)self.titleViews.lastObject;
        if (titleView) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(titleView.frame) + contentOffsetX, 0.0);
        }
    }
}

#pragma mark - 设置scrollView
- (UIScrollView *)scrollView{
    
    if (!_scrollView) {
        UIScrollView * scrollView = [[UIScrollView alloc]init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
//        scrollView.bounces = NO;
        scrollView.pagingEnabled = NO;
        scrollView.scrollsToTop = NO;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (void)setupScrollView{
    
    CGFloat extraBtnW = 44.0;
    CGFloat extraBtnY = 5.0;
    CGFloat scrollW = _extraButton ? _currentWidth - extraBtnW : _currentWidth;
    self.scrollView.frame = CGRectMake(0, 0, scrollW, self.frame.size.height);
    if (self.extraButton) {
        self.extraButton.frame = CGRectMake(scrollW, extraBtnY, extraBtnW, self.frame.size.height - 2*extraBtnY);
    }
    
}

#pragma mark - 设置titleView
- (void)setupTitleView{
    
    CGFloat titleViewX = 0.0;
    CGFloat titleViewY = 0.0;
    CGFloat titleViewW = 0.0;
    CGFloat titleViewH = self.frame.size.height - self.titleStyle.sliderHeight;
    
    if (!self.titleStyle.isScrollTitle) {//如果不是滑动的，那么平分宽度
        titleViewW = self.scrollView.bounds.size.width / self.titlesArray.count;
        NSInteger index = 0;
        for (TitleView *titleView in self.titleViews) {
            titleViewX = index * titleViewW;
            titleView.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
            index++;
        }
    }else{
        NSInteger index = 0;
        CGFloat lastTitleMaxX = self.titleStyle.titleMargin;
//        CGFloat addedMargin = 0.0;
        for (TitleView *titleView in self.titleViews) {
            titleViewW = [self.titleWidths[index] floatValue];
            titleViewX = lastTitleMaxX;
            lastTitleMaxX += self.titleStyle.titleMargin + titleViewW;
            titleView.frame = CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH);
            index ++;
        }
    }
    
    TitleView *currentTitleView = self.titleViews[_currentIndex];
    currentTitleView.currentTransformX = 1.0;
    if (currentTitleView) {
        
        if (self.titleStyle.isScaleTitle) {
            currentTitleView.currentTransformX = self.titleStyle.scaleNum;
        }
        currentTitleView.textColor = self.titleStyle.selectedTitleColor;
    }
}

#pragma mark - 设置滑动条
- (void)setupSlider{
    
    TitleView *firstTitleView = self.titleViews[0];
    CGFloat sliderX = firstTitleView.frame.origin.x;
    CGFloat sliderW = firstTitleView.frame.size.width;
    CGFloat coverH = self.titleStyle.coverHeight;
    CGFloat coverY = (self.bounds.size.height - coverH) * 0.5;
    
    if (self.sliderView) {
        if (self.titleStyle.isScrollTitle) {
            self.sliderView.frame = CGRectMake(sliderX, self.frame.size.height - self.titleStyle.sliderHeight, sliderW, self.titleStyle.sliderHeight);
        }else{
            if (self.titleStyle.sliderWidthFitTitle) {
                sliderW = [self.titleWidths[_currentIndex] floatValue] + GapWidth;
                sliderX = (firstTitleView.frame.size.width - sliderW) * 0.5;
            }
            self.sliderView.frame = CGRectMake(sliderX, self.frame.size.height - self.titleStyle.sliderHeight, sliderW, self.titleStyle.sliderHeight);
        }
    }
    
    if (self.coverLayer) {
        
        if (self.titleStyle.isScrollTitle) {
            self.coverLayer.frame = CGRectMake(sliderX - Gapx, coverY, sliderW + GapWidth, coverH);
            
        } else {
            if (self.titleStyle.isAdjustCoverOrSliderWidth) {
                sliderW = [self.titleWidths[_currentIndex] floatValue] + GapWidth;
                sliderX = (firstTitleView.frame.size.width - sliderW) * 0.5;
            }
            
            self.coverLayer.frame = CGRectMake(sliderX, coverY, sliderW, coverH);
            
        }
        
    }
    
    
}

- (UIView *)sliderView{
    
    if (!self.titleStyle.isShowSlider) return nil;
    if (!_sliderView) {
        UIView *slider = [UIView new];
        slider.backgroundColor = self.titleStyle.sliderColor;
        _sliderView = slider;
    }
    return _sliderView;
}

- (UIButton *)extraButton{
    
    if (!self.titleStyle.showExtraButton) return nil;
    if (!_extraButton) {
        UIButton *btn = [UIButton new];
        NSString *imageName = self.titleStyle.extraButtonImageName ? self.titleStyle.extraButtonImageName : @"";
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.shadowColor = [UIColor whiteColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(-6, 0);
        btn.layer.shadowOpacity = 1.0;
        [btn addTarget:self action:@selector(extraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _extraButton = btn;
    }
    return _extraButton;
}

#pragma mark - 点击手势
- (void)titleOnClick:(UITapGestureRecognizer *)tap{
    
    TitleView *currentTitleView = (TitleView *)tap.view;
    if (!currentTitleView) return;
    _currentIndex = currentTitleView.tag;
    
    [self titleOnClickWithAnimated:YES taped:YES];
}


- (void)titleOnClickWithAnimated:(BOOL)animated taped:(BOOL)taped{
    
    if (_currentIndex == _oldIndex && taped) return;
    TitleView *oldTitleView = (TitleView *)self.titleViews[_oldIndex];
    TitleView *currentTitleView = (TitleView *)self.titleViews[_currentIndex];
    CGFloat duration = animated ? 0.3:0.0;
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        
        oldTitleView.textColor = weakSelf.titleStyle.normalTitleColor;
        currentTitleView.textColor = weakSelf.titleStyle.selectedTitleColor;
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        if (weakSelf.titleStyle.isScaleTitle) {
            oldTitleView.currentTransformX = 1.0;
            currentTitleView.currentTransformX = weakSelf.titleStyle.scaleNum;
        }
        
        if (weakSelf.sliderView) {
            if (weakSelf.titleStyle.isScaleTitle) {
                CGRect rect = weakSelf.sliderView.frame;
                rect.origin.x = currentTitleView.frame.origin.x;
                rect.size.width = currentTitleView.frame.size.width;
                weakSelf.sliderView.frame = rect;
            }else{
                
                if (weakSelf.titleStyle.sliderWidthFitTitle) {
                    CGFloat sliderW = [self.titleWidths[_currentIndex] floatValue] + GapWidth;
                    CGFloat sliderX = currentTitleView.frame.origin.x + (currentTitleView.frame.size.width - sliderW) * 0.5;
                    CGRect rect = weakSelf.sliderView.frame;
                    rect.origin.x = sliderX;
                    rect.size.width = sliderW;
                    weakSelf.sliderView.frame = rect;
                }else{
                    CGRect rect = weakSelf.sliderView.frame;
                    rect.origin.x = currentTitleView.frame.origin.x;
                    rect.size.width = currentTitleView.frame.size.width;
                    weakSelf.sliderView.frame = rect;
                }
            }
        }
        
        CGRect coverRect = weakSelf.coverLayer.frame;
        if (weakSelf.coverLayer) {
            if (weakSelf.titleStyle.isScrollTitle) {
                coverRect.origin.x = currentTitleView.frame.origin.x - Gapx;
                coverRect.size.width = currentTitleView.frame.size.width + GapWidth;
                weakSelf.coverLayer.frame = coverRect;
            } else {
                
                if (self.titleStyle.isAdjustCoverOrSliderWidth) {
                    CGFloat coverW = [self.titleWidths[_currentIndex] floatValue] + GapWidth;
                    CGFloat coverX = currentTitleView.frame.origin.x + (currentTitleView.frame.size.width - coverW) * 0.5;
                    coverRect.origin.x = coverX;
                    coverRect.size.width = coverW;
                    weakSelf.coverLayer.frame = coverRect;
                } else {
                    
                    coverRect.origin.x = currentTitleView.frame.origin.x;
                    coverRect.size.width = currentTitleView.frame.size.width;
                    weakSelf.coverLayer.frame = coverRect;
                }
            }
        }
        
    } completion:^(BOOL finished) {
        
        [weakSelf adjustTitleOffsetToCurrentIndex:_currentIndex];
    }];
    
    _oldIndex = _currentIndex;
    if (self.titleDidClick) {
        self.titleDidClick(currentTitleView, _currentIndex);
    }
}

- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex{
    
    _oldIndex = currentIndex;
    int index = 0;
    for (TitleView *titleView in self.titleViews) {
        if (index != currentIndex) {
            titleView.textColor = self.titleStyle.normalTitleColor;
            titleView.currentTransformX = 1.0;
            titleView.selected = NO;
        }else{
            titleView.textColor = self.titleStyle.selectedTitleColor;
            
            if (self.titleStyle.isScaleTitle) {
                titleView.currentTransformX = self.titleStyle.scaleNum;
            }
            titleView.selected = YES;
        }
        index ++;
    }
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + contentOffsetX) {
        
        //滑动
        TitleView *titleView = (TitleView *)self.titleViews[currentIndex];
        CGFloat offset = titleView.center.x - _currentWidth * 0.5;
        if (offset < 0) {
            offset = 0;
        }
        
        CGFloat extraBtnW = self.extraButton ? self.extraButton.frame.size.width : 0;
        CGFloat maxOffsetX = self.scrollView.contentSize.width - (_currentWidth - extraBtnW);
        if (maxOffsetX < 0) {
            maxOffsetX = 0;
        }
        
        if (offset > maxOffsetX) {
            offset = maxOffsetX;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
    
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated{
    
    if (index < 0 || index >= self.titlesArray.count) return;
    _currentIndex = index;
    [self titleOnClickWithAnimated:animated taped:NO];
    
}

#pragma mark - 调整滑动条和渐变颜色
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex{
    
    if (oldIndex >= self.titlesArray.count || oldIndex < 0 || currentIndex >= self.titlesArray.count || currentIndex < 0) {
        return;
    }
    
    _oldIndex = currentIndex;
    TitleView *oldTitleView = (TitleView *)self.titleViews[oldIndex];
    TitleView *currentTitleView = (TitleView *)self.titleViews[currentIndex];
    
    CGFloat distanceX = currentTitleView.frame.origin.x - oldTitleView.frame.origin.x;
    CGFloat distanceW = currentTitleView.frame.size.width - oldTitleView.frame.size.width;
    
    CGRect rect = self.sliderView.frame;

    if (self.sliderView) {
        
        if (self.titleStyle.isScrollTitle) {
            rect.origin.x = oldTitleView.frame.origin.x + distanceX * progress;
            rect.size.width = oldTitleView.frame.size.width + distanceW * progress;
            self.sliderView.frame = rect;
        }else{
            if (self.titleStyle.sliderWidthFitTitle) {
                CGFloat oldSliderW = [self.titleWidths[oldIndex] floatValue] + GapWidth;
                CGFloat currentSliderW = [self.titleWidths[currentIndex] floatValue] + GapWidth;
                distanceW = currentSliderW - oldSliderW;
                
                CGFloat oldSliderX = oldTitleView.frame.origin.x + (oldTitleView.frame.size.width - oldSliderW) * 0.5;
                CGFloat currentSliderX = currentTitleView.frame.origin.x + (currentTitleView.frame.size.width - currentSliderW) * 0.5;
                distanceX = currentSliderX - oldSliderX;
                
                rect.origin.x = oldSliderX + distanceX * progress;
                rect.size.width = oldSliderW + distanceW * progress;
                self.sliderView.frame = rect;
                
            }else{
                rect.origin.x = oldTitleView.frame.origin.x + distanceX * progress;
                rect.size.width = oldTitleView.frame.size.width + distanceW * progress;
                self.sliderView.frame = rect;
            
            }
        }
    }
    
    if (self.coverLayer) {
        
        CGRect rect = self.coverLayer.frame;
        if (self.titleStyle.isScrollTitle) {
            
            rect.origin.x = oldTitleView.frame.origin.x + distanceX * progress - Gapx;
            rect.size.width = oldTitleView.frame.size.width + distanceW * progress + GapWidth;
            self.coverLayer.frame = rect;
            
        } else {
            if (self.titleStyle.isAdjustCoverOrSliderWidth) {
                CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue] + Gapx;
                CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue] + GapWidth;
                distanceW = currentCoverW - oldCoverW;
                CGFloat oldCoverX = oldTitleView.frame.origin.x + (oldTitleView.frame.size.width - oldCoverW) * 0.5;
                CGFloat currentCoverX = currentTitleView.frame.origin.x + (currentTitleView.frame.size.width - currentCoverW) * 0.5;
                distanceX = currentCoverX - oldCoverX;
                rect.origin.x = oldCoverX + distanceX * progress;
                rect.size.width = oldCoverW + distanceW * progress;
                self.coverLayer.frame = rect;
            } else {
                rect.origin.x = oldTitleView.frame.origin.x + distanceX * progress;
                rect.size.width = oldTitleView.frame.size.width + distanceW * progress;
                self.coverLayer.frame = rect;
                
            }
        }
    }
    
    if (self.titleStyle.isChangeTitleColor) {//渐变颜色
        oldTitleView.textColor = [UIColor colorWithRed:[self.selectedColorArray[0] floatValue] + [self.deltaRGBArray[0] floatValue] * progress green:[self.selectedColorArray[1] floatValue] + [self.deltaRGBArray[1] floatValue] * progress blue:[self.selectedColorArray[2] floatValue] + [self.deltaRGBArray[2] floatValue] * progress alpha:1];
        currentTitleView.textColor = [UIColor colorWithRed:[self.normalColorArray[0] floatValue] - [self.deltaRGBArray[0] floatValue] * progress green:[self.normalColorArray[1] floatValue] - [self.deltaRGBArray[1] floatValue] * progress blue:[self.normalColorArray[2] floatValue] - [self.deltaRGBArray[2] floatValue] * progress alpha:1];
    }
    
    if (self.titleStyle.isScaleTitle) {
        
        CGFloat deltaScale = self.titleStyle.scaleNum - 1.0;
        oldTitleView.currentTransformX = self.titleStyle.scaleNum - deltaScale * progress;
        currentTitleView.currentTransformX = 1.0 + deltaScale * progress;
    }
}

#pragma mark - 附加按钮点击
- (void)extraButtonClick:(UIButton *)btn{
    
    if (self.extraButtonClick) {
        self.extraButtonClick(btn);
    }
}

- (UIView *)coverLayer {
    if (!self.titleStyle.isShowCover) {
        return nil;
    }
    
    if (_coverLayer == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = self.titleStyle.coverBackgroundColor;
        coverView.layer.cornerRadius = self.titleStyle.coverCornerRadius;
        coverView.layer.masksToBounds = YES;
        
        _coverLayer = coverView;
        
    }
    
    return _coverLayer;
}

- (void)reloadTitles:(NSArray<NSString *> *)titles{
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _currentIndex = 0;
    _oldIndex = 0;
    self.titleViews = nil;
    self.titleWidths = nil;
    self.titlesArray = nil;
    self.titlesArray = titles.copy;
    
    if (titles.count == 0) return;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self initSubviews];
    [self setupUI];
    [self setSelectedIndex:0 animated:YES];
}

- (NSArray *)normalColorArray{
    
    if (!_normalColorArray) {
        _normalColorArray = [self getColor:self.titleStyle.normalTitleColor];
    }
    return _normalColorArray;
}

- (NSArray *)selectedColorArray{
    
    if (!_selectedColorArray) {
        _selectedColorArray = [self getColor:self.titleStyle.selectedTitleColor];
    }
    return _selectedColorArray;
}

- (NSArray *)deltaRGBArray{
    
    if (!_deltaRGBArray) {
        NSArray *deltaArr;
        if (self.normalColorArray && self.selectedColorArray) {
            CGFloat deltaR = [self.normalColorArray[0] floatValue] - [self.selectedColorArray[0] floatValue];
            CGFloat deltaG = [self.normalColorArray[1] floatValue] - [self.selectedColorArray[1] floatValue];
            CGFloat deltaB = [self.normalColorArray[2] floatValue] - [self.selectedColorArray[2] floatValue];
            deltaArr = @[@(deltaR), @(deltaG), @(deltaB)];
            _deltaRGBArray = deltaArr;
        }
    }
    return _deltaRGBArray;
}

- (NSArray *)getColor:(UIColor *)color{
    
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbComponents = @[@(components[0]), @(components[1]), @(components[2])];
    }
    return rgbComponents;
}
@end
