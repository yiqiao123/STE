//
//  FavoriteTableViewController.m
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "FavoriteTableViewController.h"
#import "MenuItem.h"
#import "PopupMenu.h"

@interface FavoriteTableViewController ()
@property (strong, nonatomic) NSMutableArray *displayQuestions;
@property (strong, nonatomic) NSMutableArray *chapter_names;
@property (strong, nonatomic) NSMutableArray *section_names;
@property (strong, nonatomic) PopupMenu *popMenu;
@end

@implementation FavoriteTableViewController
@synthesize popMenu;

- (void)refreshData{
    [self.displayQuestions removeAllObjects];
    [self.chapter_names removeAllObjects];
    [self.section_names removeAllObjects];
    ChaptersAndSections *chaptersAndSections = [ChaptersAndSections shared];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(isFavorite = %d)", YES];
    [request setPredicate:pred];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"favorite_date" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    [request setSortDescriptors:sortDescriptors];
    NSArray *questions = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *question in questions) {
        [self.displayQuestions addObject:question];
        NSManagedObject *section = [chaptersAndSections sectionWithId:[question valueForKey:@"section_id"]];
        if (section) {
            [self.section_names addObject:[section valueForKey:@"name"]];
            NSManagedObject *chapter = [chaptersAndSections chapterWithId:[section valueForKey:@"chapter_id"]];
            if (chapter) {
                [self.chapter_names addObject:[chapter valueForKey:@"name"]];
            } else {
                [self.chapter_names addObject:@""];
            }
        } else {
            [self.section_names addObject:@""];
            [self.chapter_names addObject:@""];
        }
    }

    if ([self.displayQuestions count] == 0) {
        ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"暂无收藏！";
    } else {
        ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"";
    }
    [self changeSetting];
}

- (void)changeSetting{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //int font_size = (int)[appDelegate.settings[@"font"] integerValue];
    int background_color = (int)[appDelegate.settings[@"background"] integerValue];
    if (background_color == 0) {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        if ([self.tableView.tableFooterView viewWithTag:99]) {
            ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).textColor = [UIColor darkTextColor];
        }
    } else if(background_color == 1){
        self.tableView.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
        if ([self.tableView.tableFooterView viewWithTag:99]) {
            ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).textColor = [UIColor darkTextColor];
        }
    } else if(background_color == 2){
        self.tableView.backgroundColor = [UIColor blackColor];
        if ([self.tableView.tableFooterView viewWithTag:99]) {
            ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).textColor = [UIColor lightTextColor];
        }
    }
}

- (void)clearAll{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否清楚所有收藏？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)clearAllProcess{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    for (NSManagedObject *question in self.displayQuestions) {
        [question setValue: [NSNumber numberWithBool:NO] forKey:@"isFavorite"];
    }
    [appDelegate saveContext];
    [self.displayQuestions removeAllObjects];
    [self.chapter_names removeAllObjects];
    [self.section_names removeAllObjects];
    [self refreshData];
    [self.tableView reloadData];
}

-(void)fontChange:(id)sender{
    MenuItem *item = (MenuItem *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.settings[@"font"] = [NSNumber numberWithInteger:item.value];
    [defaults setObject:[NSNumber numberWithInteger:item.value] forKey:@"font"];
    [defaults synchronize];
    [self changeSetting];
    [self.tableView reloadData];
}

-(void)backgroundChange:(id)sender{
    MenuItem *item = (MenuItem *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.settings[@"background"] = [NSNumber numberWithInteger:item.value];
    [defaults setObject:[NSNumber numberWithInteger:item.value] forKey:@"background"];
    [defaults synchronize];
    [self changeSetting];
    [self.tableView reloadData];
}

-(void)showMenu:(id)sender{
    CGRect frame = CGRectZero;
    for (UIView *view in [self.navigationController.navigationBar subviews]) {
        if (view.frame.origin.x >= frame.origin.x) {
            frame = view.frame;
        }
    }
    frame.origin.y = frame.origin.y + 20;
    [popMenu showMenuInView:self.navigationController.view fromRect:frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIBarButtonItem *moreButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pop_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(showMenu:)];
    MenuItem *fontItem = [[MenuItem alloc] initWithSegment:@"小,中,大" image:[UIImage imageNamed:@"font_pop"] target:self action:@selector(fontChange:) defaultValue:[appDelegate.settings[@"font"] integerValue]];
    MenuItem *backgroundItem = [[MenuItem alloc] initWithSegment:@"白天,护眼,夜间" image:[UIImage imageNamed:@"scene_pop"] target:self action:@selector(backgroundChange:) defaultValue:[appDelegate.settings[@"background"] integerValue]];
    popMenu = [[PopupMenu alloc] initWithItems:@[fontItem, backgroundItem]];
    UIBarButtonItem *clearAllButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(clearAll)];
    [self.navigationItem setRightBarButtonItems:@[moreButton, clearAllButton]];
    
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    float width = 200;
    float height = 40;
    CGRect theRect = CGRectMake((self.tableView.frame.size.width - width) / 2, (self.tableView.frame.size.height- self.navigationController.navigationBar.frame.size.height - 20 - self.tabBarController.tabBar.frame.size.height - height) / 2, width, height);
    UILabel *test = [[UILabel alloc] initWithFrame:theRect];
    test.font = [UIFont systemFontOfSize:30];
    test.textAlignment = NSTextAlignmentCenter;
    test.tag = 99;
    [footer addSubview:test];
    self.tableView.tableFooterView = footer;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"收藏";
    //自适应
    self.tableView.estimatedRowHeight = 271.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.displayQuestions = [NSMutableArray array];
    self.section_names = [NSMutableArray array];
    self.chapter_names = [NSMutableArray array];
    //[self refreshData];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
//        [self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
//    });
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [self refreshData];
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
        [self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)viewDidDisappear:(BOOL)animated{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.displayQuestions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell" forIndexPath:indexPath];
    [cell refreshBackgroundAndFont];
    NSManagedObject *question = self.displayQuestions[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日";
    cell.favorite_time.text = [NSString stringWithFormat:@"收藏时间：%@", [dateFormatter stringFromDate:[question valueForKey:@"favorite_date"]]];
    
    cell.chapter.text = self.chapter_names[indexPath.row];
    cell.section.text = self.section_names[indexPath.row];
    
    cell.content.text = [NSString stringWithFormat:@"%ld. %@", indexPath.row + 1, [question valueForKey:@"content"]];
    NSArray *choice_head = @[@"A", @"B", @"C", @"D"];
    for (int i = 1; i <= 4; i++) {
        NSString *choiceId = [NSString stringWithFormat:@"choice%d", i];
        UILabel *choice = (UILabel *)[cell viewWithTag:i];
        if ([question valueForKey:choiceId]) {
            choice.text = [NSString stringWithFormat:@"%@. %@", choice_head[i - 1], [question valueForKey:choiceId]];
        } else {
            choice.text = nil;
        }
        if ([(NSString *)[question valueForKey:@"answer"] containsString:choice_head[i - 1]]) {
            choice.textColor = [UIColor blueColor];
        } else {
            choice.textColor = cell.defaultTextColor;
        }
    }
    cell.analysis.text = ([question valueForKey:@"analysis"]) ? [NSString stringWithFormat:@"【答案】%@\n【解析】%@", [question valueForKey:@"answer"], [question valueForKey:@"analysis"]] : [NSString stringWithFormat:@"【答案】%@", [question valueForKey:@"answer"]];
    cell.correct_rate.text = [NSString stringWithFormat:@"【答题情况】%ld/%ld（正确/总共）", (long)[[question valueForKey:@"right_times"] integerValue], ([[question valueForKey:@"wrong_times"] integerValue] + [[question valueForKey:@"right_times"] integerValue])];
    
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
        // Delete the row from the data source
        NSManagedObject *question = self.displayQuestions[indexPath.row];
        [question setValue: [NSNumber numberWithBool:NO] forKey:@"isFavorite"];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate saveContext];
        [self.displayQuestions removeObjectAtIndex:indexPath.row];
        [self.section_names removeObjectAtIndex:indexPath.row];
        [self.chapter_names removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([self.displayQuestions count] == 0) {
            ((UILabel *)[self.tableView.tableFooterView viewWithTag:99]).text = @"暂无收藏！";
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
