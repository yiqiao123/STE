//
//  QuestionTableViewCell.m
//  STE
//
//  Created by 易乔 on 15/5/13.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "QuestionTableViewCell.h"

@implementation QuestionTableViewCell

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

    self.content.textColor = self.defaultTextColor;
    self.choice1.textColor = self.defaultTextColor;
    self.choice2.textColor = self.defaultTextColor;
    self.choice3.textColor = self.defaultTextColor;
    self.choice4.textColor = self.defaultTextColor;
    self.analysis.textColor = self.defaultTextColor;
    if (settings.font == STEFontSizeSmall) {
        self.content.font = [UIFont systemFontOfSize:13];
        self.choice1.font = [UIFont systemFontOfSize:13];
        self.choice2.font = [UIFont systemFontOfSize:13];
        self.choice3.font = [UIFont systemFontOfSize:13];
        self.choice4.font = [UIFont systemFontOfSize:13];
        self.analysis.font = [UIFont systemFontOfSize:13];
    } else if (settings.font == STEFontSizeMiddle) {
        self.content.font = [UIFont systemFontOfSize:17];
        self.choice1.font = [UIFont systemFontOfSize:17];
        self.choice2.font = [UIFont systemFontOfSize:17];
        self.choice3.font = [UIFont systemFontOfSize:17];
        self.choice4.font = [UIFont systemFontOfSize:17];
        self.analysis.font = [UIFont systemFontOfSize:17];
    } else if (settings.font == STEFontSizeBig) {
        self.content.font = [UIFont systemFontOfSize:21];
        self.choice1.font = [UIFont systemFontOfSize:21];
        self.choice2.font = [UIFont systemFontOfSize:21];
        self.choice3.font = [UIFont systemFontOfSize:21];
        self.choice4.font = [UIFont systemFontOfSize:21];
        self.analysis.font = [UIFont systemFontOfSize:21];
    }
}

@end
