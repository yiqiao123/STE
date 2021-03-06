//
//  QuestionBankTableViewController.m
//  STE
//
//  Created by 易乔 on 15/5/11.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "QuestionBankTableViewController.h"

@interface QuestionBankTableViewController ()

@property (strong, nonatomic) NSMutableArray *display_items;
@property (strong, nonatomic) TreeNode *head;

@end

@implementation QuestionBankTableViewController

- (void)changeSetting{
    STESettings *settings = [STESettings shared];
    self.tableView.backgroundColor = settings.backgroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    STESettings *settings = [STESettings shared];
    self.navigationController.navigationBar.barStyle = settings.navigationBarStyle;
    self.navigationController.navigationBar.tintColor = settings.navigationBarTintColor;

    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0];
    //self.navigationController.navigationBar.translucent = YES;
    
    
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    ChaptersAndSections *chaptersAndSections = [ChaptersAndSections shared];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 74;
    self.display_items = [NSMutableArray array];
    self.head = [[TreeNode alloc] initWithObject:nil andLevel:0];
    self.head.isExpand = YES;

    for (NSManagedObject *chapter in [chaptersAndSections allChapters]) {
        TreeNode *chapter_node = [[TreeNode alloc] initWithObject:chapter andLevel:1];
        for (NSManagedObject *section in [chaptersAndSections sectionsWithChapterId:[chapter valueForKey:@"id"]]) {
            TreeNode *section_node = [[TreeNode alloc] initWithObject:section andLevel:2];
            [chapter_node addChild:section_node];
        }
        [self.head addChild:chapter_node];
    }
    
    [self addNodeToDisplayArray: self.head];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
        [self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
    });
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeSetting];
    [self.tableView reloadData];
}

- (void)addNodeToDisplayArray: (TreeNode *) node{
    if (node != self.head) {
        [self.display_items addObject:node];
    }
    if (node.isExpand) {
        for (TreeNode *child in node.children) {
            [self addNodeToDisplayArray:child];
        }
    }
}

- (void)cellSingleTap:(UIGestureRecognizer *)recognizer
{
    UITableViewCell *cell = (UITableViewCell *)recognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TreeNode *node = self.display_items[indexPath.row];
    if (!node.isLeaf) {
        node.isExpand = !node.isExpand;
        [self.display_items removeAllObjects];
        [self addNodeToDisplayArray:self.head];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
}

- (void)imageSingleTap:(UIGestureRecognizer *)recognizer
{
    UITableViewCell *cell = (UITableViewCell *)[[recognizer.view superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TreeNode *node = self.display_items[indexPath.row];
    if (!node.isLeaf) {
        node.isExpand = !node.isExpand;
        [self.display_items removeAllObjects];
        [self addNodeToDisplayArray:self.head];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.display_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuestionBankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Directory" forIndexPath:indexPath];
    [cell refreshBackgroundAndFont];
    TreeNode *node = (TreeNode *)self.display_items[indexPath.row];
    NSManagedObject *object = [node value];

    cell.name.text = [object valueForKey:@"name"];
    
    long wrong_times = [[object valueForKey:@"wrong_times"] integerValue];
    long right_times = [[object valueForKey:@"right_times"] integerValue];
    if (wrong_times + right_times) {
        cell.correct_rate.text = [NSString stringWithFormat:@"%.2f%%", (double)right_times / (wrong_times + right_times)];
    } else {
        cell.correct_rate.text = nil;
    }
    
    if (node.isLeaf) {
        cell.nodeImage.image = nil;
        cell.show_questions.hidden = NO;
//        for (UIGestureRecognizer *gestureRecognizer in [cell gestureRecognizers]) {
//            [cell removeGestureRecognizer:gestureRecognizer];
//        }
        for (UIGestureRecognizer *gestureRecognizer in [cell.nodeImage gestureRecognizers]) {
            [cell.nodeImage removeGestureRecognizer:gestureRecognizer];
        }
    } else {
        if (node.isExpand) {
            cell.nodeImage.image = [UIImage imageNamed:@"open"];
        } else {
            cell.nodeImage.image = [UIImage imageNamed:@"close"];
        }
        cell.show_questions.hidden = YES;
//        if ([[cell gestureRecognizers] count] == 0) {
//            UITapGestureRecognizer *single = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellSingleTap:)];
//            [cell addGestureRecognizer:single];
//        }
        if ([[cell.nodeImage gestureRecognizers] count] == 0) {
            UITapGestureRecognizer *imageSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSingleTap:)];
            [cell.nodeImage addGestureRecognizer:imageSingle];
        }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    QuestionTableViewController *quesTVC = segue.destinationViewController;
    NSManagedObject *section = [(TreeNode *)self.display_items[indexPath.row] value];
    quesTVC.title = @"";
    quesTVC.sections = [NSArray arrayWithObjects:section, nil];
    quesTVC.isExam = NO;
    quesTVC.isHistory = NO;
    quesTVC.isSubmit = NO;
    quesTVC.isShowAnswer = NO;
    quesTVC.isShowFault = NO;
}


@end
