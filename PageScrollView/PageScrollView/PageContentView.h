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

@interface PageContentView : UIView

@property(nonatomic, weak)id<ScrollPageViewDelegate> delegate;
@property(nonatomic, strong)WTCollectionView *collectionView;



@end
