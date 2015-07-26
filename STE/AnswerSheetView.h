//
//  AnswerSheetView.h
//  STE
//
//  Created by 易乔 on 15/7/19.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STEPanGestureDirection) {
    STEPanGestureDirectionNone,
    STEPanGestureDirectionHorizontal,
    STEPanGestureDirectionVertical
};

static CGFloat const minAlpha = 0.3f;
static CGFloat const maxAlpha = 0.9f;

@interface AnswerSheetView : UIView


- (instancetype)initWithQuestions:(NSMutableArray *)questions sections:(NSMutableArray *)sections states:(NSMutableArray *)states frame:(CGRect)frame target:(id)target performSelector:(SEL)selector;

- (void)dismissView;

@end
