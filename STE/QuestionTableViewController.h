//
//  QuestionTableViewController.h
//  
//
//  Created by 易乔 on 15/5/13.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "QuestionTableViewCell.h"
#import "KxMenu.h"
#import "ChaptersAndSections.h"


@interface QuestionTableViewController : UITableViewController<UIAlertViewDelegate>

@property (copy, nonatomic) NSArray *sections;
@property (assign, nonatomic) BOOL isExam;
@property (assign, nonatomic) BOOL isSubmit;
@property (assign, nonatomic) BOOL isHistory;
@property (assign, nonatomic) BOOL isShowAnswer;
@property (assign, nonatomic) BOOL isShowFault;
@property (strong, nonatomic) NSManagedObject *history;

@end
