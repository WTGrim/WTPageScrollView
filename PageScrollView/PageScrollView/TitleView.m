//
//  TitleView.m
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "TitleView.h"

@interface TitleView (){
    CGSize _titleSize;
    
}

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *contentView;
@end

@implementation TitleView

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.currentTransformX = 1.0;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setCurrentTransformX:(CGFloat)currentTransformX{
    _currentTransformX = currentTransformX;
    self.transform = CGAffineTransformMakeScale(currentTransformX, currentTransformX);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    self.label.font = titleFont;
}

- (void)setText:(NSString *)text{
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.label.font} context:nil];
    _titleSize = bounds.size;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.label.textColor = textColor;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
}

- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (CGFloat)titleViewWidth{
    
    return _titleSize.width;
}

@end

@interface WTCollectionView ()

@property(nonatomic, copy)scrollViewShouldBeginPanGestureRecognizerBlock block;

@end
@implementation WTCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (_block && gestureRecognizer == self.panGestureRecognizer) {
        return _block(self, (UIPanGestureRecognizer *)gestureRecognizer);
    }else{
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (void)setScrollViewShouldBeginPanGestureRecognizer:(scrollViewShouldBeginPanGestureRecognizerBlock)block{
    _block = [block copy];
}

@end
