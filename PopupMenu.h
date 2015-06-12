//
//  PopupMenu.h
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuView.h"

@interface PopupMenu : NSObject

- (id)init;

- (id)initWithItems:(NSArray *)menuItems;

- (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect;

- (void) dismissMenu;

- (void) addMenuItem:(MenuItem *)menuItem;

- (void) deleteMenuItem: (MenuItem *)menuItem;

@end
