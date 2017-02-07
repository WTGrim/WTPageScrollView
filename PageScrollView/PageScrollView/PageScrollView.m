//
//  PageScrollView.m
//  PageScrollView
//
//  Created by Dwt on 2017/2/7.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PageScrollView.h"

@interface PageScrollView ()

@property(nonatomic, weak)PageContentView *contentView;
@property(nonatomic, weak)SegmentScrollView *segmentView;
@property(nonatomic, strong)PageTitleStyle *titleStyle;

@property(nonatomic, strong)NSArray *titles;
//@property(nonatomic, strong)NSArray *childVcs;
@property(nonatomic, weak)UIViewController *parentViewController;

@end
@implementation PageScrollView

- (instancetype)initWithFrame:(CGRect)frame titleStyle:(PageTitleStyle *)titleStyle titles:(NSArray<NSString *> *)titles parentViewController:(UIViewController *)parentViewController delegate:(id<ScrollPageViewDelegate>)delegate{
    
    if (self = [super initWithFrame:frame]) {
        self.titleStyle = titleStyle;
        self.titles = titles.copy;
        self.parentViewController = parentViewController;
        self.delegate = delegate;
        [self commonInit];
    }
    return self;
}


- (void)commonInit{
    
    self.segmentView.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated{
    
    [self.segmentView setSelectedIndex:selectedIndex animated:animated];
}

- (void)reloadTitleAndContent:(NSArray<NSString *> *)titles{
    
    self.titles = nil;
    self.titles = titles.copy;
    
    [self.segmentView reloadTitles:self.titles];
    [self.contentView reload];
}

- (PageContentView *)contentView{
    
    if (!_contentView) {
        PageContentView *contentView = [[PageContentView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.segmentView.frame)) segmentView:self.segmentView parentViewController:self.parentViewController delegate:self.delegate];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (SegmentScrollView *)segmentView{
    
    if (!_segmentView) {
        __weak typeof(self)weakSelf = self;
        SegmentScrollView *segmentView = [[SegmentScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.titleStyle.sliderHeight) titleStyle:self.titleStyle delegate:self.delegate titlesArray:self.titles titleDidClick:^(TitleView *titleView, NSInteger index) {
           
            [weakSelf.contentView setContentOffset:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:self.titleStyle.isContentAnimatedWhenTitleClick];
        }];
        [self addSubview:segmentView];
        _segmentView = segmentView;
    }
    return _segmentView;
}

- (NSArray *)titles{
    if (!_titles) {
        _titles = [NSArray array];
    }
    return _titles;
}

- (void)setExtraBtnClick:(ExtraBtnClick)extraBtnClick{
    
    _extraBtnClick = extraBtnClick;
    self.segmentView.extraButtonClick = extraBtnClick;
}


@end
