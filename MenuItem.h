//
//  MenuItem.h
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuItem : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *title;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;
//0 no; 1 button; 2 segment
@property (assign, nonatomic) int type;
@property (strong, nonatomic) UIColor *foreColor;
@property (assign, nonatomic) NSTextAlignment alignment;
@property (assign, nonatomic) NSInteger value;

- (id) initWithButton:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action;

- (id) initWithSegment:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action defaultValue: (NSInteger) value;

- (void) performAction: (id)sender;

@end
