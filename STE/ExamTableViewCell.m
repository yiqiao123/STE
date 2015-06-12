//
//  ExamTableViewCell.m
//  STE
//
//  Created by 易乔 on 15/5/28.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "ExamTableViewCell.h"

@implementation ExamTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshBackgroundAndFont{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //int font_size = (int)[appDelegate.settings[@"font"] integerValue];
    int background_color = (int)[appDelegate.settings[@"background"] integerValue];
    if (background_color == 0) {
        self.backgroundColor = [UIColor whiteColor];
        self.defaultTextColor = [UIColor darkTextColor];
    } else if(background_color == 1){
        self.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
        self.defaultTextColor = [UIColor darkTextColor];
    } else if(background_color == 2){
        self.backgroundColor = [UIColor blackColor];
        self.defaultTextColor = [UIColor lightTextColor];
    }
    self.name.textColor = self.defaultTextColor;
}

@end
