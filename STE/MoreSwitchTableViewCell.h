//
//  MoreSwitchTableViewCell.h
//  STE
//
//  Created by 易乔 on 15/5/31.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MoreSwitchTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UISwitch *setting;
@property (strong, nonatomic) UIColor *defaultTextColor;

- (void)refreshBackgroundAndFont;
@end
