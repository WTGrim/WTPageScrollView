//
//  TitleView.h
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleView : UIView

@property(nonatomic, assign)CGFloat currentTransformX;
@property(nonatomic, strong)NSString *text;
@property(nonatomic, strong)UIColor *textColor;
@property(nonatomic, strong)UIFont *titleFont;
@property(nonatomic, assign, getter=isSelected)BOOL selected;
@property(nonatomic, strong, readonly)UILabel *label;

- (CGFloat)titleViewWidth;
//- (void)adjustSubViewsFrame;

@end



@interface WTCollectionView : UICollectionView

typedef BOOL(^scrollViewShouldBeginPanGestureRecognizerBlock)(WTCollectionView *collectionView, UIPanGestureRecognizer *panGestureRecognizer);

- (void)setScrollViewShouldBeginPanGestureRecognizer:(scrollViewShouldBeginPanGestureRecognizerBlock)block;

@end
