//
//  MenuOverlay.m
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "MenuOverlay.h"
#import "MenuView.h"

@implementation MenuOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UITapGestureRecognizer *gestureRecognizer;
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}


- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[MenuView class]] && [v respondsToSelector:@selector(dismissMenu)]) {
            //[v performSelector:@selector(dismissMenu:) withObject:@(YES)];
            [v performSelector:@selector(dismissMenu)];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
