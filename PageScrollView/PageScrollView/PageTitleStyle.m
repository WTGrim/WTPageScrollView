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
        
        _showLine = NO;
        _scaleTitle = NO;
        _scrollTitle = YES;
        _changeTitleColor = YES;
        _contentAnimatedWhenTitleClick = YES;
        _adjustTitleBeginDrag = NO;
        _lineColor = [UIColor redColor];
        _normalTitleColor = [UIColor blackColor];
        _selectedTitleColor = [UIColor redColor];
        _scaleNum = 1.2;
        _titleFont = [UIFont systemFontOfSize:13];
    }
    return self;
}

@end
