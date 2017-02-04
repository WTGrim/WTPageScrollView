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
            self.titleStyle.scaleTitle = !self.titleStyle.isShowLine;  //放大标题和滑条不同时使用
        }
        
        [self initSubviews];
    }
    return self;
}


- (void)initSubviews{
    
    [self addSubview:self.scrollView];
    if (self.titleStyle.showLine) {
        [self addSubview:self.sliderView];
    }
    [self setTitles];
    [self setupUI];
}

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
    
}

- (void)titleOnClick:(UITapGestureRecognizer *)tap{
    
}
@end
