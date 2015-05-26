//
//  QuestionTableViewCell.h
//  STE
//
//  Created by 易乔 on 15/5/13.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *choice1;
@property (strong, nonatomic) IBOutlet UILabel *choice2;
@property (strong, nonatomic) IBOutlet UILabel *choice3;
@property (strong, nonatomic) IBOutlet UILabel *choice4;
@property (strong, nonatomic) IBOutlet UILabel *analysis;
@property (strong, nonatomic) IBOutlet UIImageView *favoriteImage;

@end
