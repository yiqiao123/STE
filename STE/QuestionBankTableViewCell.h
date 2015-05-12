//
//  QuestionBankTableViewCell.h
//  STE
//
//  Created by 易乔 on 15/5/12.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionBankTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *nodeImage;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *correct_rate;


@end
