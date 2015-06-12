//
//  QuestionResultViewController.m
//  STE
//
//  Created by 易乔 on 15/5/24.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "QuestionResultViewController.h"
#import "QuestionTableViewController.h"

@interface QuestionResultViewController ()

@end

@implementation QuestionResultViewController
@synthesize history;

- (void)changeSetting{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //int font_size = (int)[appDelegate.settings[@"font"] integerValue];
    int background_color = (int)[appDelegate.settings[@"background"] integerValue];
    if (background_color == 0) {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        for (UIView *subview in [self.view subviews]) {
            if ([subview class] == [UILabel class]) {
                ((UILabel *)subview).textColor = [UIColor darkTextColor];
            }
        }
    } else if(background_color == 1){
        self.view.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
        for (UIView *subview in [self.view subviews]) {
            if ([subview class] == [UILabel class]) {
                ((UILabel *)subview).textColor = [UIColor darkTextColor];
            }
        }
    } else if(background_color == 2){
        self.view.backgroundColor = [UIColor blackColor];
        for (UIView *subview in [self.view subviews]) {
            if ([subview class] == [UILabel class]) {
                ((UILabel *)subview).textColor = [UIColor lightTextColor];
            }
        }
    }
    self.points.textColor = [UIColor redColor];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[history valueForKey:@"isExam"] boolValue]) {
        self.questionType.text = @"智能出题";
    } else{
        self.questionType.text = [NSString stringWithFormat:@"刷题（%@）", [history valueForKey:@"section_name"]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
    self.submitDate.text = [dateFormatter stringFromDate:[history valueForKey:@"date"]];
    self.points.text = [[history valueForKey:@"points"] stringValue];
    self.total_points.text = [NSString stringWithFormat:@"/%@题", [history valueForKey:@"total_points"]];
    self.single_points.text = [[history valueForKey:@"single_points"] stringValue];
    self.single_total_points.text = [NSString stringWithFormat:@"/%@题", [history valueForKey:@"single_total_points"]];
    self.mutiple_points.text = [[history valueForKey:@"mutiple_points"] stringValue];
    self.mutiple_total_points.text = [NSString stringWithFormat:@"/%@题", [history valueForKey:@"mutiple_total_points"]];
    self.judge_points.text = [[history valueForKey:@"judge_points"] stringValue];
    self.judge_total_points.text = [NSString stringWithFormat:@"/%@题", [history valueForKey:@"judge_total_points"]];
    
    if ([[history valueForKey:@"total_points"] integerValue] == [[history valueForKey:@"points"] integerValue]) {
        [self.wrong_analysis_button setEnabled:false];
    }
    //[self changeSetting];
}

- (void)viewWillAppear:(BOOL)animated{
    [self changeSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)wrongAnalysis:(id)sender {
    UINavigationController *temp = self.navigationController;
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionTableViewController *qtvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionTableView"];
    qtvc.history = self.history;
    qtvc.isHistory = YES;
    qtvc.isShowAnswer = NO;
    qtvc.isSubmit = YES;
    qtvc.isShowFault = YES;
    qtvc.isExam = [[history valueForKey:@"isExam"] boolValue];
    qtvc.title = @"错题解析";
    [temp pushViewController:qtvc animated:YES];
}

- (IBAction)allAnalysis:(id)sender {
    UINavigationController *temp = self.navigationController;
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionTableViewController *qtvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionTableView"];
    qtvc.history = self.history;
    qtvc.isHistory = YES;
    qtvc.isShowAnswer = NO;
    qtvc.isSubmit = YES;
    qtvc.isShowFault = NO;
    qtvc.isExam = [[history valueForKey:@"isExam"] boolValue];
    qtvc.title = @"全部解析";
    [temp pushViewController:qtvc animated:YES];
}
@end
