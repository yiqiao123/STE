//
//  PopupMenu.m
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "PopupMenu.h"


@interface PopupMenu()

@property (strong, nonatomic) MenuView *menuView;


@end

@implementation PopupMenu

- (id)init{
    self = [super init];
    if (self) {
        self.menuView = [[MenuView alloc] init];
    }
    return self;
}

- (id)initWithItems:(NSArray *)menuItems{
    self = [super init];
    if (self) {
        self.menuView = [[MenuView alloc] initWithItems:menuItems];
    }
    return self;
}

- (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect{
    [self.menuView showMenuInView:view fromRect:rect];
}

- (void) dismissMenu{
    [self.menuView dismissMenu];
}

- (void) addMenuItem:(MenuItem *)menuItem{
    [self.menuView addMenuItem:menuItem];
}

- (void) deleteMenuItem: (MenuItem *)menuItem{
    [self.menuView deleteMenuItem:menuItem];
}

@end
