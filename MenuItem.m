//
//  MenuItem.m
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem
- (id) initWithButton:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action{
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.target = target;
        self.action = action;
        self.type = 1;
    }
    return self;
}

- (id) initWithSegment:(NSString *) title image:(UIImage *) image target:(id)target action:(SEL) action defaultValue:(NSInteger)value{
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.target = target;
        self.action = action;
        self.type = 2;
        self.value = value;
    }
    return self;
}

- (void) performAction: (id)sender{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        self.value = [(UISegmentedControl *)sender selectedSegmentIndex];
    }
    __strong id target = self.target;
    if (target && [target respondsToSelector:self.action]) {
        [target performSelectorOnMainThread:self.action withObject:self waitUntilDone:YES];
    }
}
@end
