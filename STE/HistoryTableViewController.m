//
//  HistoryTableViewController.m
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "QuestionResultViewController.h"
#import "QuestionTableViewController.h"

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSMutableArray *displayHistorys;

@end

@implementation HistoryTableViewController
@synthesize displayHistorys;
- (void)refreshData{
    for (UIView *subview in [self.tableView.tableFooterView subviews]) {
        if ([subview class] == [UIActivityIndicatorView class]) {
            [(UIActivityIndicatorView *)subview startAnimating];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [displayHistorys removeAllObjects];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kHistory];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
        [request setSortDescriptors:sortDescriptors];
        NSArray *histories = [context executeFetchRequest:request error:&error];
        for (NSManagedObject *history in histories) {
            [displayHistorys addObject:history];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in [self.tableView.tableFooterView subviews]) {
                if ([subview class] == [UIActivityIndicatorView class]) {
                    [(UIActivityIndicatorView *)subview stopAnimating];
                }
            }
            if ([displayHistorys count] == 0) {
                ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"暂无历史记录！";
            } else {
                ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"";
            }
            [self.tableView reloadData];
        });
    });
    
}

- (void)changeSetting{
    STESettings *settings = [STESettings shared];
    self.tableView.backgroundColor = settings.backgroundColor;
    if ([self.tableView.tableFooterView viewWithTag:99]) {
        ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).textColor = settings.textColor;
    }
}

- (void)clearAll{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清除所有答题历史？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)clearAllProcess{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    for (NSManagedObject *history in displayHistorys) {
        [context deleteObject:history];
    }
    [appDelegate saveContext];
    [self refreshData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    STESettings *settings = [STESettings shared];
    self.navigationController.navigationBar.barStyle = settings.navigationBarStyle;
    self.navigationController.navigationBar.tintColor = settings.navigationBarTintColor;
    
    UIBarButtonItem *clearAllButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(clearAll)];
    [self.navigationItem setRightBarButtonItems:@[clearAllButton]];
    
    //footer
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    float width = 300;
    float height = 40;
    CGRect theRect = CGRectMake((self.tableView.frame.size.width - width) / 2, (self.tableView.frame.size.height- self.navigationController.navigationBar.frame.size.height - 20 - height) / 2, width, height);
    UILabel *test = [[UILabel alloc] initWithFrame:theRect];
    test.font = [UIFont systemFontOfSize:30];
    test.textAlignment = NSTextAlignmentCenter;
    test.tag = 99;
    [footer addSubview:test];
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    if (settings.background == STEBackgroundStyleDark) {
        style = UIActivityIndicatorViewStyleWhite;
    }
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    activityView.frame = CGRectMake((self.tableView.frame.size.width - 20.0f) / 2, (self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - 20.0f) / 2, 20.0f, 20.0f);
    [footer addSubview:activityView];
    
    self.tableView.tableFooterView = footer;

    displayHistorys = [NSMutableArray array];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"HistoryviewWillAppear");
    [self changeSetting];
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //NSLog(@"HistoryviewWillDisappear");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //NSLog(@"HistoryviewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //NSLog(@"HistoryviewDidDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cellTap:(UIGestureRecognizer *)recognizer
{
    UITableViewCell *cell = (UITableViewCell *)recognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSManagedObject *history = displayHistorys[indexPath.row];
    //未提交
    if (![[history valueForKey:@"isSubmit"] boolValue]) {
        UINavigationController *temp = self.navigationController;
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QuestionTableViewController *qtvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionTableView"];
        qtvc.history = history;
        qtvc.isHistory = YES;
        qtvc.isShowAnswer = NO;
        qtvc.isSubmit = NO;
        qtvc.isShowFault = NO;
        qtvc.isExam = [[history valueForKey:@"isExam"] boolValue];
        qtvc.title = [[history valueForKey:@"isExam"] boolValue] ? @"智能出题" : @"刷题";
        [temp pushViewController:qtvc animated:YES];
    }
    //已提交
    else {
        UINavigationController *temp = self.navigationController;
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QuestionResultViewController *qrvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionResult"];
        qrvc.history = history;
        qrvc.title = @"答题结果";
        [temp pushViewController:qrvc animated:YES];
    }
    
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clearAllProcess];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [displayHistorys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history_cell" forIndexPath:indexPath];
    STESettings *settings = [STESettings shared];
    cell.backgroundColor = settings.backgroundColor;
    cell.textLabel.textColor = settings.textColor;
    
    NSManagedObject *history = displayHistorys[indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日 hh:mm";
    NSString *date = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[history valueForKey:@"date"]]];
    NSString *isExam = [[history valueForKey:@"isExam"] boolValue] ? @"，智能出题" : @"，刷题";
    NSString *isSubmit = [[history valueForKey:@"isSubmit"] boolValue] ? @"已交卷" : @"未提交";
    NSString *point = [[history valueForKey:@"isSubmit"] boolValue] ? [NSString stringWithFormat:@"，答对题数：%@/%@", [history valueForKey:@"points"], [history valueForKey:@"total_points"]] : @"";
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@\n%@%@", date, isExam, isSubmit, point];
    
    
    NSString *section_name = [[history valueForKey:@"isExam"] boolValue] ? @"" : [history valueForKey:@"section_name"];
    cell.detailTextLabel.text = section_name;
    
    for (UIGestureRecognizer *gestureRecognizer in [cell gestureRecognizers]) {
        [cell removeGestureRecognizer:gestureRecognizer];
    }
    
    UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    if ([[cell gestureRecognizers] count] == 0) {
        [cell addGestureRecognizer:cellTap];
    }
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kHistoryQuestion];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(history_id = %@)", [displayHistorys[indexPath.row] valueForKey:@"id"]];
        [request setPredicate:pred];
        NSArray *history_questions = [context executeFetchRequest:request error:&error];
        for (NSManagedObject *history_question in history_questions) {
            [context deleteObject:history_question];
        }
        [context deleteObject:displayHistorys[indexPath.row]];
        [displayHistorys removeObjectAtIndex:indexPath.row];
        [appDelegate saveContext];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([displayHistorys count] == 0) {
            ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"暂无历史记录！";
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
