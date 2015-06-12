//
//  FavoriteTableViewCell.m
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "FavoriteTableViewCell.h"

@implementation FavoriteTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshBackgroundAndFont{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    int font_size = (int)[appDelegate.settings[@"font"] integerValue];
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
    self.content.textColor = self.defaultTextColor;
    self.choice1.textColor = self.defaultTextColor;
    self.choice2.textColor = self.defaultTextColor;
    self.choice3.textColor = self.defaultTextColor;
    self.choice4.textColor = self.defaultTextColor;
    self.analysis.textColor = self.defaultTextColor;
    self.favorite_time.textColor = self.defaultTextColor;
    self.chapter.textColor = self.defaultTextColor;
    self.section.textColor = self.defaultTextColor;

    if (font_size == 0) {
        self.content.font = [UIFont systemFontOfSize:13];
        self.choice1.font = [UIFont systemFontOfSize:13];
        self.choice2.font = [UIFont systemFontOfSize:13];
        self.choice3.font = [UIFont systemFontOfSize:13];
        self.choice4.font = [UIFont systemFontOfSize:13];
        self.analysis.font = [UIFont systemFontOfSize:13];
        self.correct_rate.font = [UIFont systemFontOfSize:13];
        self.favorite_time.font = [UIFont systemFontOfSize:11];
        self.chapter.font = [UIFont systemFontOfSize:11];
        self.section.font = [UIFont systemFontOfSize:11];
    } else if (font_size == 1) {
        self.content.font = [UIFont systemFontOfSize:17];
        self.choice1.font = [UIFont systemFontOfSize:17];
        self.choice2.font = [UIFont systemFontOfSize:17];
        self.choice3.font = [UIFont systemFontOfSize:17];
        self.choice4.font = [UIFont systemFontOfSize:17];
        self.analysis.font = [UIFont systemFontOfSize:17];
        self.correct_rate.font = [UIFont systemFontOfSize:17];
        self.favorite_time.font = [UIFont systemFontOfSize:13];
        self.chapter.font = [UIFont systemFontOfSize:13];
        self.section.font = [UIFont systemFontOfSize:13];
    } else if (font_size == 2) {
        self.content.font = [UIFont systemFontOfSize:21];
        self.choice1.font = [UIFont systemFontOfSize:21];
        self.choice2.font = [UIFont systemFontOfSize:21];
        self.choice3.font = [UIFont systemFontOfSize:21];
        self.choice4.font = [UIFont systemFontOfSize:21];
        self.analysis.font = [UIFont systemFontOfSize:21];
        self.correct_rate.font = [UIFont systemFontOfSize:21];
        self.favorite_time.font = [UIFont systemFontOfSize:15];
        self.chapter.font = [UIFont systemFontOfSize:15];
        self.section.font = [UIFont systemFontOfSize:15];
    }
}

@end
