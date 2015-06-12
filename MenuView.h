//
//  MenuView.h
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
#import "MenuOverlay.h"

@interface MenuView : UIView
@property (strong, nonatomic) UIColor *foreColor;

- (id)initWithItems:(NSArray *)menuItems_l;

- (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect;

- (void) dismissMenu;

- (void) addMenuItem:(MenuItem *)menuItem_l;

- (void) deleteMenuItem: (MenuItem *)menuItem_l;

@end
