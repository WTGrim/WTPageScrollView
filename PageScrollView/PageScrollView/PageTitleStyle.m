//
//  PageTitleStyle.m
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PageTitleStyle.h"

@implementation PageTitleStyle

- (instancetype)init{
    if (self = [super init]) {
        
        _showSlider = NO;
        _scaleTitle = NO;
        _showExtraButton = NO;
        _extraButtonImageName = nil;
        _scrollTitle = YES;
        _changeTitleColor = YES;
        _contentAnimatedWhenTitleClick = YES;
        _adjustTitleBeginDrag = NO;
        _sliderColor = [UIColor redColor];
        _sliderWidthFitTitle = NO;
        _sliderHeight = 2.0;
        
        _coverBackgroundColor = [UIColor whiteColor];
        _coverHeight = 28.0;
        _coverCornerRadius = 14.0;
        
        _adjustCoverOrSliderWidth = NO;
        
        _titleMargin = 15.0;
        _normalTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _selectedTitleColor = [UIColor colorWithRed:255.0 / 255.0 green:0 blue:0 alpha:1];
        _scaleNum = 1.2;
        _titleFont = [UIFont systemFontOfSize:13];
        
        _segmentHeight = 44.0;
        
    }
    return self;
}

@end
