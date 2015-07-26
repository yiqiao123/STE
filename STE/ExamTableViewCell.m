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
    STESettings *settings = [STESettings shared];
    self.backgroundColor = settings.backgroundColor;
    self.defaultTextColor = settings.textColor;
    self.name.textColor = self.defaultTextColor;
}

@end
