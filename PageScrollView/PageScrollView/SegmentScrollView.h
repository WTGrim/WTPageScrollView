//
//  SegmentScrollView.h
//  PageScrollView
//
//  Created by Dwt on 2017/2/4.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageTitleStyle.h"
#import "TitleView.h"
#import "PageScrollViewDelegate.h"


typedef void(^TitleDidClick)(TitleView *titleView, NSInteger index);
typedef void(^ExtraButtonClick)(UIButton *extraButton);

@interface SegmentScrollView : UIView

@property(nonatomic, strong)NSArray *titlesArray;
@property(nonatomic, strong)PageTitleStyle *titleStyle;
@property(nonatomic, weak)id<ScrollPageViewDelegate>delegate;
@property(nonatomic, strong)UIImage *backgroundImage;
@property(nonatomic, copy)ExtraButtonClick extraButtonClick;

- (instancetype)initWithFrame:(CGRect)frame titleStyle:(PageTitleStyle *)titleStyle delegate:(id<ScrollPageViewDelegate>)delegate titlesArray:(NSArray *)titlesArray titleDidClick:(TitleDidClick)titleDidClick;

//切换下标调整UI
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;
//选中标题
- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex;
//设置选中下标
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
//刷新
- (void)reloadTitles:(NSArray<NSString *>*)titles;
@end
