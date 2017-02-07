//
//  PageScrollView.h
//  PageScrollView
//
//  Created by Dwt on 2017/2/7.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentView.h"
#import "TitleView.h"
#import "SegmentScrollView.h"

typedef void(^ExtraBtnClick)(UIButton *btn);

@interface PageScrollView : UIView

@property(nonatomic, copy)ExtraBtnClick extraBtnClick;
@property(nonatomic, weak, readonly)PageContentView *contentView;
@property(nonatomic, weak, readonly)SegmentScrollView *segmentView;

@property(nonatomic, weak)id<ScrollPageViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame titleStyle:(PageTitleStyle *)titleStyle titles:(NSArray<NSString *> *)titles parentViewController:(UIViewController *)parentViewController delegate:(id<ScrollPageViewDelegate>)delegate;

//设置选中下标
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

//刷新新标题和内容视图
- (void)reloadTitleAndContent:(NSArray<NSString *> *)titles;

@end
