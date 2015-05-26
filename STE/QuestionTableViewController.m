//
//  QuestionTableViewController.m
//  
//
//  Created by 易乔 on 15/5/13.
//
//

#import "QuestionTableViewController.h"
#import "QuestionResultViewController.h"

@interface QuestionTableViewController ()

@property (strong, nonatomic) NSMutableArray *displayQuestions;
@property (strong, nonatomic) NSMutableArray *historyQuestions;
@property (strong, nonatomic) NSMutableArray *displayIndexes;
@property (strong, nonatomic) NSMutableArray *displaySections;
@property (assign, nonatomic) BOOL isToBottom;
@property (assign, nonatomic) BOOL isToTop;

@end

@implementation QuestionTableViewController

@synthesize sections;
@synthesize isExam;
@synthesize isHistory;
@synthesize isShowAnswer;
@synthesize isSubmit;
@synthesize isShowFault;
@synthesize history;

@synthesize displayQuestions;
@synthesize displayIndexes;
@synthesize displaySections;
@synthesize historyQuestions;
@synthesize isToBottom;
@synthesize isToTop;

//显示答案
- (void)showAnswer{
    isShowAnswer = true;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    for (NSArray *questions in historyQuestions) {
        for (NSManagedObject *question in questions) {
            [context deleteObject:question];
        }
    }
    [context deleteObject:history];
    [appDelegate saveContext];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItems:@[]];
}

//交卷操作
- (void)submit
{
    BOOL hasUndo = false;
    for (NSArray *history__section_questions in historyQuestions) {
        for (NSManagedObject *history_question in history__section_questions) {
            BOOL isDo = NO;
            for (int j = 1; j <= 4; j++) {
                isDo = isDo | [[history_question valueForKey:[NSString stringWithFormat:@"choose%d", j]] boolValue];
            }
            if (!isDo) {
                hasUndo = true;
                break;
                break;
            }
        }
    }
    if (hasUndo) {
        //提示有未做题
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"有未做题，是否提交？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    } else{
        [self submitProcess];
    }
}

//交卷
- (void)submitProcess{
    ChaptersAndSections *chaptersAndSections = [ChaptersAndSections shared];
    int total_points = 0;
    int type_numbers = (int)[historyQuestions count];
    int each_array[type_numbers];
    memset(each_array, 0, type_numbers * sizeof(int));
    for (int i = 0; i < type_numbers; i++) {
        for (int j = 0; j < [historyQuestions[i] count]; j++) {
            NSManagedObject *question = displayQuestions[i][j];
            NSManagedObject *history_question = historyQuestions[i][j];
            NSString *answer = [question valueForKey:@"answer"];
            NSArray *answer_choice = @[@"A", @"B", @"C", @"D"];
            BOOL isCorrect = YES;
            for (int k = 0; k < [answer_choice count]; k++) {
                if ([answer containsString:answer_choice[k]] ^ [[history_question valueForKey:[NSString stringWithFormat:@"choose%d", k + 1]] boolValue] ) {
                    isCorrect = NO;
                }
            }
            //更新节做题数
            NSManagedObject *section = [chaptersAndSections sectionWithId:[question valueForKey:@"section_id"]];
            if (section) {
                NSManagedObject *chapter = [chaptersAndSections chapterWithId:[section valueForKey:@"chapter_id"]];
                //更新章做题数
                if (chapter) {
                    if (isCorrect) {
                        [chapter setValue:[NSNumber numberWithInteger:([[chapter valueForKey:@"right_times"] integerValue] + 1)] forKey:@"right_times"];
                    } else {
                        [chapter setValue:[NSNumber numberWithInteger:([[chapter valueForKey:@"wrong_times"] integerValue] + 1)] forKey:@"wrong_times"];
                    }
                }
                if (isCorrect) {
                    [section setValue:[NSNumber numberWithInteger:([[section valueForKey:@"right_times"] integerValue] + 1)] forKey:@"right_times"];
                } else {
                    [section setValue:[NSNumber numberWithInteger:([[section valueForKey:@"wrong_times"] integerValue] + 1)] forKey:@"wrong_times"];
                }
            }
            
            //更新此题信息
            if (isCorrect) {
                [question setValue:[NSNumber numberWithInteger:([[question valueForKey:@"right_times"] integerValue] + 1)] forKey:@"right_times"];
            } else {
                [question setValue:[NSNumber numberWithInteger:([[question valueForKey:@"wrong_times"] integerValue] + 1)] forKey:@"wrong_times"];
            }
            [history_question setValue:[NSNumber numberWithBool:isCorrect] forKey:@"correct"];
            total_points++;
            if (isCorrect) {
                each_array[i]++;
            }
        }
    }
    [history setValue:[NSDate date] forKey:@"date"];
    [history setValue:[NSNumber numberWithBool:YES] forKey:@"isSubmit"];
    [history setValue:[NSNumber numberWithInt:total_points] forKey:@"total_points"];
    [history setValue:[NSNumber numberWithInt:(each_array[0] + each_array[1] + each_array[2])] forKey:@"points"];
    [history setValue:[NSNumber numberWithLong:[historyQuestions[0] count]] forKey:@"single_total_points"];
    [history setValue:[NSNumber numberWithInt:each_array[0]] forKey:@"single_points"];
    [history setValue:[NSNumber numberWithLong:[historyQuestions[1] count]] forKey:@"mutiple_total_points"];
    [history setValue:[NSNumber numberWithInt:each_array[1]] forKey:@"mutiple_points"];
    [history setValue:[NSNumber numberWithLong:[historyQuestions[2] count]] forKey:@"judge_total_points"];
    [history setValue:[NSNumber numberWithInt:each_array[2]] forKey:@"judge_points"];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
    
    
    UINavigationController *temp = self.navigationController;
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionResultViewController *qrvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QuestionResult"];
    qrvc.history = self.history;
    qrvc.title = @"答题结果";
    [temp popViewControllerAnimated:NO];
    [temp pushViewController:qrvc animated:NO];
}


//寻找下一个未做题
- (void)nextUndo
{
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (!visibleRows) {
        return;
    }
    NSIndexPath *current;
    //分界线顶格时0元素为分界线顶格上一个的元素
    if ([visibleRows count] > 1) {
        current = visibleRows[1];
    } else if ([visibleRows count] == 1){
        current = visibleRows[0];
    } else {
        return;
    }
    if (isToBottom) {
        //current设置为最后一个元素
        current = [NSIndexPath indexPathForRow:([[historyQuestions lastObject] count] - 1) inSection:([historyQuestions count] - 1)];
    }
    if (isToTop) {
        //current设置为第一个元素
        current = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    //遍历整个数组
    for (int i = (int)current.section; i <= current.section + [historyQuestions count]; i++) {
        int start = 0;
        int end = (int)[historyQuestions[i % [historyQuestions count]] count] - 1;
        if (i == current.section) {
            start = (int)current.row + 1;
        }
        if (i == current.section + [historyQuestions count]) {
            end = (int)current.row;
        }
        for (; start <= end; start++) {
            NSManagedObject *history_question = historyQuestions[i % [historyQuestions count]][start];
            BOOL isDo = NO;
            for (int j = 1; j <= 4; j++) {
                isDo = isDo | [[history_question valueForKey:[NSString stringWithFormat:@"choose%d", j]] boolValue];
            }
            if (!isDo) {
                //是否翻转；如果翻转则先跳到第一行；如果最开始在第一行，则跳到最后一行
                if (i == current.section + [historyQuestions count]) {
                    if (isToTop) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[historyQuestions lastObject] count] - 1) inSection:([historyQuestions count] - 1)] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    } else {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:start inSection:(i % [historyQuestions count])] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }

        }
    }
    //提示全部已做
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"恭喜" message:@"全部已做！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

//寻找下一个错题
- (void)nextFault
{
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (!visibleRows) {
        return;
    }
    NSIndexPath *current;
    //分界线顶格时0元素为分界线顶格上一个的元素
    if ([visibleRows count] > 1) {
        current = visibleRows[1];
    } else if ([visibleRows count] == 1){
        current = visibleRows[0];
    } else {
        return;
    }
    if (isToBottom) {
        //current设置为最后一个元素
        current = [NSIndexPath indexPathForRow:([[historyQuestions lastObject] count] - 1) inSection:([historyQuestions count] - 1)];
    }
    if (isToTop) {
        //current设置为第一个元素
        current = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    //遍历整个数组
    for (int i = (int)current.section; i <= current.section + [historyQuestions count]; i++) {
        int start = 0;
        int end = (int)[historyQuestions[i % [historyQuestions count]] count] - 1;
        if (i == current.section) {
            start = (int)current.row + 1;
        }
        if (i == current.section + [historyQuestions count]) {
            end = (int)current.row;
        }
        for (; start <= end; start++) {
            NSManagedObject *history_question = historyQuestions[i % [historyQuestions count]][start];
            BOOL isFault = ![[history_question valueForKey:@"correct"] boolValue];
            if (isFault) {
                //是否翻转；如果翻转则先跳到第一行；如果最开始在第一行，则跳到最后一行
                if (i == current.section + [historyQuestions count]) {
                    if (isToTop) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[historyQuestions lastObject] count] - 1) inSection:([historyQuestions count] - 1)] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    } else {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:start inSection:(i % [historyQuestions count])] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            
        }
    }
    //提示全部已做
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"恭喜" message:@"全部正确！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (!isSubmit) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if (![history isFault]) {
            [history setValue:[NSDate date] forKey:@"date"];
        }
        [appDelegate saveContext];
    }
}

- (void)applicationWillResignActive{
    if (!isSubmit) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if (![history isFault]) {
            [history setValue:[NSDate date] forKey:@"date"];
        }
        [appDelegate saveContext];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //增加响应ResignActive事件
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    //自适应
    self.tableView.estimatedRowHeight = 187.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //索引设置
    self.tableView.sectionIndexColor = [UIColor grayColor];

    UIBarButtonItem *more=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"open"] style:UIBarButtonItemStyleDone target:self action: @selector(popViewController)];
    
    UIBarButtonItem *nextUndoButton =[[UIBarButtonItem alloc] initWithTitle:@"->未做" style:UIBarButtonItemStyleDone target:self action: @selector(nextUndo)];
    UIBarButtonItem *nextFaultButton =[[UIBarButtonItem alloc] initWithTitle:@"->错题" style:UIBarButtonItemStyleDone target:self action: @selector(nextFault)];
    UIBarButtonItem *submitButton =[[UIBarButtonItem alloc] initWithTitle:@"交卷" style:UIBarButtonItemStyleDone target:self action: @selector(submit)];
    UIBarButtonItem *showAnswerButton =[[UIBarButtonItem alloc] initWithTitle:@"显示答案" style:UIBarButtonItemStyleDone target:self action: @selector(showAnswer)];
    UIBarButtonItem *barButtonItemLeft2=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"open"] style:UIBarButtonItemStyleDone target:self action: @selector(popViewController)];
    

    //数据初始化
    displayIndexes = [NSMutableArray arrayWithArray:@[@"单", @"多", @"判"]];
    displaySections = [NSMutableArray arrayWithArray:@[@"一、单选题", @"二、多选题", @"三、判断题"]];
    displayQuestions = [NSMutableArray array];
    historyQuestions = [NSMutableArray array];
    for (NSString *index in displaySections) {
        [displayQuestions addObject:[NSMutableArray array]];
        [historyQuestions addObject:[NSMutableArray array]];
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    if (isHistory) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kHistoryQuestion];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(history_id = %@)", [history valueForKey:@"id"]];
        [request setPredicate:pred];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"question_number" ascending:YES];
        NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
        [request setSortDescriptors:sortDescriptors];
        NSArray *history_questions = [context executeFetchRequest:request error:&error];
        //仅显示错题
        if (isShowFault && isSubmit) {
            [self.navigationItem setRightBarButtonItems:@[]];
            for (NSManagedObject *history_question in history_questions) {
                //答题错误
                if (![[history_question valueForKey:@"correct"] boolValue]) {
                    NSFetchRequest *request1 = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
                    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"(id = %@)", [history_question valueForKey:@"question_id"]];
                    [request1 setPredicate:pred1];
                    NSArray *questions = [context executeFetchRequest:request1 error:&error];
                    if ([questions count] > 0) {
                        NSManagedObject *question = questions[0];
                        [displayQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:question];
                        [historyQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:history_question];
                    }
                }
            }
        } else {
            if (isSubmit) {
                [self.navigationItem setRightBarButtonItems:@[nextFaultButton]];
            } else {
               [self.navigationItem setRightBarButtonItems:@[nextUndoButton, submitButton, showAnswerButton]]; 
            }
            for (NSManagedObject *history_question in history_questions) {
                NSFetchRequest *request1 = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
                NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"(id = %@)", [history_question valueForKey:@"question_id"]];
                [request1 setPredicate:pred1];
                NSArray *questions = [context executeFetchRequest:request1 error:&error];
                if ([questions count] > 0) {
                    NSManagedObject *question = questions[0];
                    [displayQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:question];
                    [historyQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:history_question];
                }
            }
        }
    } else {
        if (!isExam) {
            [self.navigationItem setRightBarButtonItems:@[nextUndoButton, submitButton, showAnswerButton]];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(section_id = %@)", [sections[0] valueForKey:@"id"]];
            [request setPredicate:pred];
            NSArray *questions = [context executeFetchRequest:request error:&error];
            
            
            int history_id = (int) [[NSDate date] timeIntervalSince1970];
            NSFetchRequest *history_request = [[NSFetchRequest alloc] initWithEntityName:kHistory];
            NSPredicate *history_pred = [NSPredicate predicateWithFormat:@"(id = %d)", history_id];
            [history_request setPredicate:history_pred];
            NSArray *histories = [context executeFetchRequest:history_request error:&error];
            if ([histories count] > 0) {
                history = histories[0];
            } else {
                history = [NSEntityDescription insertNewObjectForEntityForName:kHistory inManagedObjectContext:context];
            }
            [history setValue:[NSNumber numberWithInt:history_id] forKey:@"id"];
            [history setValue:[NSDate date] forKey:@"date"];
            [history setValue:[NSNumber numberWithBool:NO] forKey:@"isExam"];
            [history setValue:[sections[0] valueForKey:@"name"] forKey:@"section_name"];
            [history setValue:[NSNumber numberWithBool:NO] forKey:@"isSubmit"];

            NSFetchRequest *history_question_request = [[NSFetchRequest alloc] initWithEntityName:kHistoryQuestion];
            NSPredicate *history_question_pred = [NSPredicate predicateWithFormat:@"(history_id = %d)", history_id];
            [history_question_request setPredicate:history_question_pred];
            NSArray *history_questiones = [context executeFetchRequest:history_question_request error:&error];
            for (NSManagedObject *history_question in history_questiones) {
                [context deleteObject:history_question];
            }
            
            //TODO shuffle
            
            int question_index = 0;
            for (NSManagedObject *question in questions) {
                [displayQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:question];
                NSManagedObject *history_question = [NSEntityDescription insertNewObjectForEntityForName:kHistoryQuestion inManagedObjectContext:context];
                [history_question setValue:[NSNumber numberWithInt:history_id] forKey:@"history_id"];
                [history_question setValue:[question valueForKey:@"id"] forKey:@"question_id"];
                [history_question setValue:[NSNumber numberWithInt:(history_id * 1000 + question_index)] forKey:@"id"];
                [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose1"];
                [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose2"];
                [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose3"];
                [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose4"];
                [historyQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:history_question];
                question_index++;
            }
            int question_number = 1;
            for (NSArray *history_question_section in historyQuestions) {
                for (NSManagedObject *history_question in history_question_section) {
                    [history_question setValue:[NSNumber numberWithInt:question_number] forKey:@"question_number"];
                    question_number++;
                }
            }
        } else {
            //TODO
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
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

- (void)cellLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        QuestionTableViewCell *cell = (QuestionTableViewCell *)recognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSManagedObject *object = self.displayQuestions[indexPath.section][indexPath.row];
        [object setValue: [NSNumber numberWithBool: ![[object valueForKey:@"isFavorite"] boolValue]]   forKey:@"isFavorite"];
        [object setValue:[NSDate date] forKey:@"favorite_date"];
        cell.favoriteImage.highlighted = !cell.favoriteImage.highlighted;
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate saveContext];
    }
}

- (void)imageTap:(UIGestureRecognizer *)recognizer
{
    QuestionTableViewCell *cell = (QuestionTableViewCell *)[[recognizer.view superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSManagedObject *object = self.displayQuestions[indexPath.section][indexPath.row];
    [object setValue: [NSNumber numberWithBool: ![[object valueForKey:@"isFavorite"] boolValue]]   forKey:@"isFavorite"];
    [object setValue:[NSDate date] forKey:@"favorite_date"];
    cell.favoriteImage.highlighted = !cell.favoriteImage.highlighted;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

- (void)labelTap:(UIGestureRecognizer *)recognizer
{
    UILabel *choice = (UILabel *)recognizer.view;
    QuestionTableViewCell *cell = (QuestionTableViewCell *)[[choice superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSManagedObject *object = self.displayQuestions[indexPath.section][indexPath.row];
    NSManagedObject *history_object = self.historyQuestions[indexPath.section][indexPath.row];
    NSString *chooseId = [NSString stringWithFormat:@"choose%ld", choice.tag];
    //多选
    if ([[object valueForKey:@"type"] integerValue] == 2) {
        [history_object setValue:[NSNumber numberWithBool: ![[history_object valueForKey:chooseId] boolValue]] forKey:chooseId];
    }
    //单选或判断
    else {
        //已选泽
        if ([[history_object valueForKey:chooseId] boolValue]) {
            [history_object setValue:[NSNumber numberWithBool: ![[history_object valueForKey:chooseId] boolValue]] forKey:chooseId];
        }
        //未选择
        else {
            for (int i = 1; i <= 4; i++) {
                [history_object setValue:[NSNumber numberWithBool: NO] forKey:[NSString stringWithFormat:@"choose%d", i]];
            }
            [history_object setValue:[NSNumber numberWithBool: YES] forKey:chooseId];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -Scroll view delegate
//判断动画是否结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

}

//判断是否滑动到顶部或底部
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    isToBottom = false;
    isToTop = false;
    if (scrollView.contentOffset.y == 0 - self.navigationController.navigationBar.frame.size.height - 20) {
        isToTop = true;
    }
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        isToBottom = true;
    }
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self submitProcess];
    }
}


#pragma mark - Table view data source
     
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [displayQuestions[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Question" forIndexPath:indexPath];
    NSManagedObject *object = displayQuestions[indexPath.section][indexPath.row];
    NSManagedObject *history_question = historyQuestions[indexPath.section][indexPath.row];
    cell.favoriteImage.highlighted = [[object valueForKey:@"isFavorite"] boolValue];

    NSArray *choice_head = @[@"A", @"B", @"C", @"D"];
    if (isShowAnswer) {
        int question_num = 0;
        for (int i = 0; i < indexPath.section; i++) {
            question_num += [displayQuestions[i] count];
        }
        question_num += indexPath.row + 1;
        cell.content.text = [NSString stringWithFormat:@"%d. %@", question_num, [object valueForKey:@"content"]];
        
        for (int i = 1; i <= 4; i++) {
            NSString *choiceId = [NSString stringWithFormat:@"choice%d", i];
            UILabel *choice = (UILabel *)[cell viewWithTag:i];
            if ([object valueForKey:choiceId]) {
                choice.text = [NSString stringWithFormat:@"%@. %@", choice_head[i - 1], [object valueForKey:choiceId]];
                for (UIGestureRecognizer *gestureRecognizer in [choice gestureRecognizers]) {
                    [choice removeGestureRecognizer:gestureRecognizer];
                }
            } else {
                choice.text = nil;
                for (UIGestureRecognizer *gestureRecognizer in [choice gestureRecognizers]) {
                    [choice removeGestureRecognizer:gestureRecognizer];
                }
            }
            if ([(NSString *)[object valueForKey:@"answer"] containsString:choice_head[i - 1]]) {
                choice.textColor = [UIColor greenColor];
            } else {
                choice.textColor = [UIColor blackColor];
            }
        }
        cell.analysis.text = ([object valueForKey:@"analysis"]) ? [NSString stringWithFormat:@"【答案】%@\n【解析】%@", [object valueForKey:@"answer"], [object valueForKey:@"analysis"]] : [NSString stringWithFormat:@"【答案】%@", [object valueForKey:@"answer"]];
    } else if(isSubmit) {
        cell.content.text = [NSString stringWithFormat:@"%ld. %@", [[history_question valueForKey:@"question_number"] integerValue], [object valueForKey:@"content"]];
        
        for (int i = 1; i <= 4; i++) {
            NSString *choiceId = [NSString stringWithFormat:@"choice%d", i];
            NSString *chooseId = [NSString stringWithFormat:@"choose%d", i];
            UILabel *choice = (UILabel *)[cell viewWithTag:i];
            if ([[history_question valueForKey:chooseId] boolValue]) {
                choice.textColor = [UIColor blueColor];
            } else {
                choice.textColor = [UIColor blackColor];
            }
            if ([object valueForKey:choiceId]) {
                BOOL isCorrect = YES;
                NSString *correct_sign = @"✓";
                if ([(NSString *)[object valueForKey:@"answer"] containsString:choice_head[i - 1]] ^ [[history_question valueForKey:chooseId] boolValue]) {
                    correct_sign = @"✕";
                    isCorrect = NO;
                }
                NSMutableAttributedString *choice_str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@. %@", correct_sign, choice_head[i - 1], [object valueForKey:choiceId]]];
                if (isCorrect) {
                    [choice_str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0,1)];
                } else {
                    [choice_str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,1)];
                }
                choice.attributedText = choice_str;
                for (UIGestureRecognizer *gestureRecognizer in [choice gestureRecognizers]) {
                    [choice removeGestureRecognizer:gestureRecognizer];
                }
            } else {
                choice.text = nil;
                for (UIGestureRecognizer *gestureRecognizer in [choice gestureRecognizers]) {
                    [choice removeGestureRecognizer:gestureRecognizer];
                }
            }
        }
        //答题错误
        if (![[history_question valueForKey:@"correct"] boolValue]) {
            cell.analysis.textColor = [UIColor redColor];
        } else {
            cell.analysis.textColor = [UIColor greenColor];
        }
        cell.analysis.text = ([object valueForKey:@"analysis"]) ? [NSString stringWithFormat:@"【答案】%@\n【解析】%@", [object valueForKey:@"answer"], [object valueForKey:@"analysis"]] : [NSString stringWithFormat:@"【答案】%@", [object valueForKey:@"answer"]];
    } else {
        cell.content.text = [NSString stringWithFormat:@"%ld. %@", [[history_question valueForKey:@"question_number"] integerValue], [object valueForKey:@"content"]];
        
        for (int i = 1; i <= 4; i++) {
            UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
            NSString *choiceId = [NSString stringWithFormat:@"choice%d", i];
            NSString *chooseId = [NSString stringWithFormat:@"choose%d", i];
            UILabel *choice = (UILabel *)[cell viewWithTag:i];
            if ([object valueForKey:choiceId]) {
                choice.text = [NSString stringWithFormat:@"%@. %@", choice_head[i - 1], [object valueForKey:choiceId]];
                if ([[choice gestureRecognizers] count] == 0) {
                    [choice addGestureRecognizer:labelTap];
                }
                if ([[history_question valueForKey:chooseId] boolValue]) {
                    choice.textColor = [UIColor blueColor];
                } else {
                    choice.textColor = [UIColor blackColor];
                }
            } else {
                choice.text = nil;
                for (UIGestureRecognizer *gestureRecognizer in [choice gestureRecognizers]) {
                    [choice removeGestureRecognizer:gestureRecognizer];
                }
            }
        }
        cell.analysis.text = nil;
    }

    
    for (UIGestureRecognizer *gestureRecognizer in [cell gestureRecognizers]) {
        [cell removeGestureRecognizer:gestureRecognizer];
    }

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    if ([[cell gestureRecognizers] count] == 0) {
        [cell addGestureRecognizer:longPress];
    }
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    if ([[cell.favoriteImage gestureRecognizers] count] == 0) {
        [cell.favoriteImage addGestureRecognizer:imageTap];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return displaySections[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return displayIndexes;
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
