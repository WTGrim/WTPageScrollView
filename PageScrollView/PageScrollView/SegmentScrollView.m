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

- (instancetype)initWithFrame:(CGRect)frame titleStyle:(PageTitleStyle *)titleStyle delegate:(id<ScrollPageViewDelegate>)delegate titlesArray:(NSArray *)titlesArray titleDidClick:(TitleDidClick)titleDidClick{
    
    if (self = [super initWithFrame:frame]) {
        self.titleStyle = titleStyle;
        self.delegate = delegate;
        self.titlesArray = titlesArray;
        self.titleDidClick = titleDidClick;
        if (!self.titleStyle.isScrollTitle) {
            self.titleStyle.scaleTitle = !self.titleStyle.isShowSlider;  //放大标题和滑条不同时使用
        }
        
        [self initSubviews];
        [self setupUI];
    }
    return self;
}


- (void)initSubviews{
    
    [self addSubview:self.scrollView];
    
    if (self.titleStyle.isShowSlider) {
        [self addSubview:self.sliderView];
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
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(titleView.frame), 0.0);
        }
    }
}

#pragma mark - 设置scrollView
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
    
    
}

- (UIView *)sliderView{
    
    if (!self.titleStyle.showSlider) return nil;
    if (!self.sliderView) {
        UIView *slider = [UIView new];
        slider.backgroundColor = self.titleStyle.sliderColor;
        self.sliderView = slider;
    }
    return self.sliderView;
}

- (UIButton *)extraButton{
    
    if (!self.titleStyle.showExtraButton) return nil;
    if (!_extraButton) {
        UIButton *btn = [UIButton new];
        NSString *imageName = self.titleStyle.extraButtonImageName ? self.titleStyle.extraButtonImageName : @"";
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.shadowColor = [UIColor whiteColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(-8, 0);
        btn.layer.shadowOpacity = 1.0;
        [btn addTarget:self action:@selector(extraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _extraButton = btn;
    }
    return _extraButton;
}

- (void)titleOnClick:(UITapGestureRecognizer *)tap{
    
    TitleView *currentTitleView = (TitleView *)tap.view;
    if (!currentTitleView) return;
    _currentIndex = currentTitleView.tag;
    
    [self btnOnClickWithAnimated:YES taped:YES];
}

- (void)btnOnClickWithAnimated:(BOOL)animated taped:(BOOL)taped{
    
    if (_currentIndex == _oldIndex && taped) return;
    TitleView *oldTitleView = (TitleView *)self.titleViews[_oldIndex];
    TitleView *currentTitleView = (TitleView *)self.titleViews[_currentIndex];
    CGFloat duration = animated ? 0.3:0.0;
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
       
        
    }];
}

- (void)extraButtonClick:(UIButton *)btn{
    
}
@end
