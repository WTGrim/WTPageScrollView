//
//  PageContentView.h
//  PageScrollView
//
//  Created by Dwt on 2017/1/23.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollViewDelegate.h"
#import "TitleView.h"
#import "SegmentScrollView.h"

@interface PageContentView : UIView

@property(nonatomic, weak)id<ScrollPageViewDelegate> delegate;
@property(nonatomic, strong, readonly)WTCollectionView *collectionView;

- (instancetype)initWithFrame:(CGRect)frame segmentView:(SegmentScrollView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<ScrollPageViewDelegate>)delegate;

- (void)setContentOffset:(CGFloat)offset animated:(BOOL)animated;
- (void)reload;

@end
