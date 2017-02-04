//
//  PageTitleStyle.h
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageTitleStyle : NSObject
//显示滑动条，默认是NO
@property(nonatomic, assign, getter=isShowSlider)BOOL showSlider;
//显示附加按钮
@property(nonatomic, assign, getter=isShowExtraButton)BOOL showExtraButton;

//缩放标题文字,默认是NO
@property(nonatomic, assign, getter=isScaleTitle)BOOL scaleTitle;
//是否能滚动标题
@property(nonatomic, assign, getter=isScrollTitle)BOOL scrollTitle;
//是否有渐变颜色
@property(nonatomic, assign, getter=isChangeTitleColor)BOOL changeTitleColor;
//点击标题内容视图是否有动画
@property(nonatomic, assign, getter=isContentAnimatedWhenTitleClick)BOOL contentAnimatedWhenTitleClick;
//开始滑动的时候就调整title的位置，默认是YES
@property(nonatomic, assign, getter=isAdjustTitleBeginDrag)BOOL adjustTitleBeginDrag;
//当scrollTitle设置为NO时，将lineWidthFitTitle设置为yes，可将滑动条的宽度适配文字宽度，默认为NO
@property(nonatomic, assign, getter=isLineWidthFitTitle)BOOL sliderWidthFitTitle;
//滑动条颜色
@property(nonatomic, strong)UIColor *sliderColor;
@property(nonatomic, assign)CGFloat sliderHeight;
@property(nonatomic, assign)CGFloat titleMargin;
@property(nonatomic, strong)NSString *extraButtonImageName;
@property(nonatomic, strong)UIColor *normalTitleColor;
@property(nonatomic, strong)UIColor *selectedTitleColor;
@property(nonatomic, strong)UIFont *titleFont;

//标题缩放倍数
@property(nonatomic, assign)CGFloat scaleNum;
@end
