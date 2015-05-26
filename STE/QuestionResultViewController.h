//
//  QuestionResultViewController.h
//  STE
//
//  Created by 易乔 on 15/5/24.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface QuestionResultViewController : UIViewController
@property (strong, nonatomic) NSManagedObject *history;

@property (strong, nonatomic) IBOutlet UILabel *questionType;
@property (strong, nonatomic) IBOutlet UILabel *submitDate;
@property (strong, nonatomic) IBOutlet UILabel *points;
@property (strong, nonatomic) IBOutlet UILabel *total_points;
@property (strong, nonatomic) IBOutlet UILabel *single_points;
@property (strong, nonatomic) IBOutlet UILabel *single_total_points;
@property (strong, nonatomic) IBOutlet UILabel *mutiple_points;
@property (strong, nonatomic) IBOutlet UILabel *mutiple_total_points;
@property (strong, nonatomic) IBOutlet UILabel *judge_points;
@property (strong, nonatomic) IBOutlet UILabel *judge_total_points;
- (IBAction)wrongAnalysis:(id)sender;
- (IBAction)allAnalysis:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *wrong_analysis_button;


@end
