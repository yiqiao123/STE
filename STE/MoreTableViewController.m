//
//  MoreTableViewController.m
//  STE
//
//  Created by 易乔 on 15/5/31.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "MoreTableViewController.h"

@interface MoreTableViewController ()

@property (strong, nonatomic) NSArray *displayItems;
@property (strong, nonatomic) NSArray *displaySectionTitles;
@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = @"其他";
    
    //类型 名字 favorite_name static segment
    self.displayItems = @[
        //section 0
        @[
            //row 0
            @[@"skip", @"答题历史"]
        ],
        //section 1
        @[
            //row 0
            @[@"segment", @"字体", @"font", @[@"小", @"中", @"大"]],
            //row 1
            @[@"segment", @"背景", @"background", @[@"白天", @"护眼", @"夜晚"]],
            //row 2
            @[@"switch", @"长按收藏", @"isLongPressFavor"]
        ],
        //section 2
        @[
            //row 0
            @[@"switch", @"显示答案", @"isShowAnswer"]
        ],
        //section 3
        @[
            //row 0
            @[@"switch", @"错题优先", @"isFaultPrefer"]
        ]
    ];
    self.displaySectionTitles = @[@"", @"通用设置", @"开启后，刷题时自动显示答案。", @"开启后，智能出题时优先筛选以往答题中正确率较低的题目。"];
    
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)changeSetting{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //int font_size = (int)[appDelegate.settings[@"font"] integerValue];
    int background_color = (int)[appDelegate.settings[@"background"] integerValue];
    if (background_color == 0) {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    } else if(background_color == 1){
        self.tableView.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
    } else if(background_color == 2){
        self.tableView.backgroundColor = [UIColor blackColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self changeSetting];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(id)sender{
    MoreSegmentTableViewCell *cell = (MoreSegmentTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *item = self.displayItems[indexPath.section][indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.settings[item[2]] = [NSNumber numberWithInteger:[cell.setting selectedSegmentIndex]];
    [defaults setObject:[NSNumber numberWithInteger:[cell.setting selectedSegmentIndex]] forKey:item[2]];
    [defaults synchronize];
    [self changeSetting];
    [self.tableView reloadData];
}

- (IBAction)switchChanged:(id)sender{
    MoreSwitchTableViewCell *cell = (MoreSwitchTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *item = self.displayItems[indexPath.section][indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.settings[item[2]] = [NSNumber numberWithBool:cell.setting.isOn];
    [defaults setObject:[NSNumber numberWithBool:cell.setting.isOn] forKey:item[2]];
    [defaults synchronize];
    [self changeSetting];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.displayItems[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.displaySectionTitles[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSArray *item = self.displayItems[indexPath.section][indexPath.row];
    if ([(NSString *)item[0] compare:@"skip"] == NSOrderedSame) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreSkip" forIndexPath:indexPath];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        //int font_size = (int)[appDelegate.settings[@"font"] integerValue];
        int background_color = (int)[appDelegate.settings[@"background"] integerValue];
        if (background_color == 0) {
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor darkTextColor];
        } else if(background_color == 1){
            cell.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
            cell.textLabel.textColor = [UIColor darkTextColor];
        } else if(background_color == 2){
            cell.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor lightTextColor];
        }
        cell.textLabel.text = item[1];
        return cell;
    } else if([(NSString *)item[0] compare:@"segment"] == NSOrderedSame){
        MoreSegmentTableViewCell *cell = (MoreSegmentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MoreSegment" forIndexPath:indexPath];
        [cell refreshBackgroundAndFont];
        cell.title.text = item[1];
        [cell.setting removeAllSegments];
        if (item[3]) {
            for (int i = 0; i < [item[3] count]; i++) {
                [cell.setting insertSegmentWithTitle:item[3][i] atIndex:i animated:NO];
            }
        }
        [cell.setting setSelectedSegmentIndex:[appDelegate.settings[item[2]] integerValue]];
        return cell;
    } else if([(NSString *)item[0] compare:@"switch"] == NSOrderedSame){
        MoreSwitchTableViewCell *cell = (MoreSwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MoreSwitch" forIndexPath:indexPath];
        [cell refreshBackgroundAndFont];
        cell.title.text = item[1];
        [cell.setting setOn:[appDelegate.settings[item[2]] boolValue]];
        return cell;
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
