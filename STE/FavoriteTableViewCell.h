//
//  FavoriteTableViewCell.h
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *choice1;
@property (strong, nonatomic) IBOutlet UILabel *choice2;
@property (strong, nonatomic) IBOutlet UILabel *choice3;
@property (strong, nonatomic) IBOutlet UILabel *choice4;
@property (strong, nonatomic) IBOutlet UILabel *analysis;
@property (strong, nonatomic) IBOutlet UILabel *correct_rate;
@property (strong, nonatomic) IBOutlet UILabel *favorite_time;
@property (strong, nonatomic) IBOutlet UILabel *chapter;
@property (strong, nonatomic) IBOutlet UILabel *section;
@end
