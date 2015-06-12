//
//  ExamTableViewCell.h
//  STE
//
//  Created by 易乔 on 15/5/28.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ExamTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *nodeImage;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *correct_rate;
@property (strong, nonatomic) UIColor *defaultTextColor;

- (void)refreshBackgroundAndFont;
@end
