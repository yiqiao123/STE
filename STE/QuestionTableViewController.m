//
//  QuestionTableViewController.m
//  
//
//  Created by 易乔 on 15/5/13.
//
//

#import "QuestionTableViewController.h"
#import "QuestionResultViewController.h"
#import "PopupMenu.h"
#import "MenuItem.h"

@interface QuestionTableViewController ()

@property (strong, nonatomic) NSMutableArray *displayQuestions;
@property (strong, nonatomic) NSMutableArray *historyQuestions;
//@property (strong, nonatomic) NSMutableArray *displayIndexes;
@property (strong, nonatomic) NSMutableArray *displaySections;
@property (assign, nonatomic) BOOL isToBottom;
@property (assign, nonatomic) BOOL isToTop;

@property (assign, nonatomic) BOOL isFaultPrefer_setting;
@property (assign, nonatomic) BOOL isLongPressFavor_setting;
@property (strong, nonatomic) PopupMenu *popMenu;

@property (strong, nonatomic) AnswerSheetView *asView;
@property (strong, nonatomic) NSMutableArray *questionNumbers;
@property (strong, nonatomic) NSMutableArray *questionStates;

@end

@implementation QuestionTableViewController

@synthesize sections;
@synthesize isExam;
@synthesize isHistory;
@synthesize isShowAnswer;
@synthesize isSubmit;
@synthesize isShowFault;
@synthesize history;

@synthesize isFaultPrefer_setting;
@synthesize isLongPressFavor_setting;

@synthesize displayQuestions;
//@synthesize displayIndexes;
@synthesize displaySections;
@synthesize historyQuestions;
@synthesize isToBottom;
@synthesize isToTop;

@synthesize popMenu;

@synthesize asView;
@synthesize questionNumbers;
@synthesize questionStates;

//洗牌
- (void)shuffle:(NSMutableArray *) array{
    int num = (int)[array count];
    for (int i = num; i > 1; i--) {
        int random = arc4random() % i;
        if (random != i - 1) {
            id temp = array[random];
            array[random] = array[i - 1];
            array[i - 1] = temp;
        }
    }
}

//出题
- (NSMutableArray *)generateQuestion:(NSMutableArray *)questions withQuestionNum:(int)questionNum andFaultPrefer:(BOOL) isFaultPrefer_local
{
    NSMutableArray *return_array = [NSMutableArray array];
    int num = (int)[questions count];
    if (num == 0) {
        return return_array;
    }
    //错题优先
    if (isFaultPrefer_local) {
        int question_weight[num];
        for (int i = 0 ; i < num; i++) {
            int wrong_time = (int)[[questions[i] valueForKey:@"wrong_times"] integerValue];
            int right_time = (int)[[questions[i] valueForKey:@"right_times"] integerValue];
            question_weight[i] = (int)((float)(wrong_time + 1) / (right_time + wrong_time + 2) * 10000);
            if (i > 0) {
                question_weight[i] = question_weight[i] + question_weight[i - 1];
            }
        }
        for (int j = 0; j < questionNum; j++) {
            if (question_weight[num - 1] == 0) {
                break;
            }
            int random = arc4random() % question_weight[num - 1] + 1;
            int k = 0;
            for (; k < num; k++) {
                if (random <= question_weight[k]) {
                    break;
                }
            }
            [return_array addObject:questions[k]];
            int choose_weight = question_weight[k];
            if (k != 0) {
                choose_weight = question_weight[k] - question_weight[k - 1];
            }
            for (; k < num; k++) {
                question_weight[k] = question_weight[k] - choose_weight;
            }
        }
    }
    //随机出题
    else {
        int j = 0;
        for (int i = num; i > 1; i--) {
            if (j >= questionNum) {
                break;
            }
            int random = arc4random() % i;
            if (random != i - 1) {
                id temp = questions[random];
                questions[random] = questions[i - 1];
                questions[i - 1] = temp;
            }
            [return_array addObject:questions[i - 1]];
            j++;
        }
    }
    [self shuffle:return_array];
    
    return return_array;
}

//显示答案
- (void)showAnswer: (id)sender{
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
    
    [popMenu dismissMenu];
    UIBarButtonItem *moreButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pop_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(showMenu:)];
    [self.navigationItem setRightBarButtonItems:@[moreButton]];
    STESettings *settings = [STESettings shared];
    MenuItem *fontItem = [[MenuItem alloc] initWithSegment:@"小,中,大" image:[UIImage imageNamed:@"font_pop"] target:self action:@selector(fontChange:) defaultValue:settings.font];
    MenuItem *backgroundItem = [[MenuItem alloc] initWithSegment:@"白天,护眼,夜间" image:[UIImage imageNamed:@"scene_pop"] target:self action:@selector(backgroundChange:) defaultValue:settings.background];
    popMenu = [[PopupMenu alloc] initWithItems:@[fontItem, backgroundItem]];
    
    for (int j = 0; j < [questionStates count]; j++) {
        for (int i = 0; i < [questionStates[j] count]; i++) {
            [questionStates[j] replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:STEQuestionStateUndo]];
            [[NSNotificationCenter defaultCenter] postNotificationName:nQuestionState object:nil userInfo:@{@"state": [NSNumber numberWithInteger:STEQuestionStateUndo], @"indexPath": [NSIndexPath indexPathForRow:i inSection:j]}];
        }
    }
}

//交卷操作
- (void)submit
{
    BOOL hasUndo = false;
    for (NSArray *section_states in questionStates) {
        for (NSNumber *state in section_states) {
            if ([state integerValue] == STEQuestionStateUndo) {
                hasUndo = true;
                break;
                break;
            }
        }
    }
    [popMenu dismissMenu];
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
    [temp pushViewController:qrvc animated:YES];
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
        current = [NSIndexPath indexPathForRow:([[questionStates lastObject] count] - 1) inSection:([questionStates count] - 1)];
    }
    if (isToTop) {
        //current设置为第一个元素
        current = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    //遍历整个数组
    for (int i = (int)current.section; i <= current.section + [questionStates count]; i++) {
        int start = 0;
        int end = (int)[questionStates[i % [questionStates count]] count] - 1;
        if (i == current.section) {
            start = (int)current.row + 1;
        }
        if (i == current.section + [questionStates count]) {
            end = (int)current.row;
        }
        for (; start <= end; start++) {
             if ([questionStates[i % [questionStates count]][start] integerValue]== STEQuestionStateUndo) {
                //是否翻转；如果翻转则先跳到第一行；如果最开始在第一行，则跳到最后一行
                if (i == current.section + [questionStates count]) {
                    if (isToTop) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[questionStates lastObject] count] - 1) inSection:([questionStates count] - 1)] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    } else {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:start inSection:(i % [questionStates count])] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        current = [NSIndexPath indexPathForRow:([[questionStates lastObject] count] - 1) inSection:([questionStates count] - 1)];
    }
    if (isToTop) {
        //current设置为第一个元素
        current = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    //遍历整个数组
    for (int i = (int)current.section; i <= current.section + [questionStates count]; i++) {
        int start = 0;
        int end = (int)[questionStates[i % [questionStates count]] count] - 1;
        if (i == current.section) {
            start = (int)current.row + 1;
        }
        if (i == current.section + [questionStates count]) {
            end = (int)current.row;
        }
        for (; start <= end; start++) {
            if ([questionStates[i % [questionStates count]][start] integerValue] == STEQuestionStateFault) {
                //是否翻转；如果翻转则先跳到第一行；如果最开始在第一行，则跳到最后一行
                if (i == current.section + [historyQuestions count]) {
                    if (isToTop) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([[questionStates lastObject] count] - 1) inSection:([questionStates count] - 1)] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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

-(void)fontChange:(id)sender{
    MenuItem *item = (MenuItem *)sender;
    STESettings *settings = [STESettings shared];
    settings.font = item.value;
    [self changeSetting];
    [self.tableView reloadData];
}

-(void)backgroundChange:(id)sender{
    MenuItem *item = (MenuItem *)sender;
    STESettings *settings = [STESettings shared];
    settings.background = item.value;
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

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)changeSetting{
    STESettings *settings = [STESettings shared];
    self.tableView.backgroundColor = settings.backgroundColor;
    if ([self.tableView.tableHeaderView viewWithTag:99]) {
        ((UILabel *)[self.tableView.tableHeaderView viewWithTag:99]).textColor = settings.textColor;
    }
    //self.tableView.sectionIndexBackgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;

    //增加响应ResignActive事件
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    //自适应
    self.tableView.estimatedRowHeight = 187.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //索引设置
    //self.tableView.sectionIndexColor = [UIColor grayColor];
    
    STESettings *settings = [STESettings shared];
    
    //footer
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    if (settings.background == STEBackgroundStyleDark) {
        style = UIActivityIndicatorViewStyleWhite;
    }
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    activityView.frame = CGRectMake((self.tableView.frame.size.width - 20.0f) / 2, (self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - 20.0f) / 2 - self.tableView.contentSize.height, 20.0f, 20.0f);
    [footer addSubview:activityView];
    self.tableView.tableFooterView = footer;
    for (UIView *subview in [self.tableView.tableFooterView subviews]) {
        if ([subview class] == [UIActivityIndicatorView class]) {
            [(UIActivityIndicatorView *)subview startAnimating];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.5];
        UIBarButtonItem *nextUndoButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next_undo_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(nextUndo)];
        UIBarButtonItem *nextFaultButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"next_wrong_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(nextFault)];
        
        MenuItem *submitItem = [[MenuItem alloc] initWithButton:@"交卷" image:[UIImage imageNamed:@"submit_pop"] target:self action:@selector(submit)];
        MenuItem *showAnswerItem = [[MenuItem alloc] initWithButton:@"显示答案" image:[UIImage imageNamed:@"show_answer_pop"] target:self action:@selector(showAnswer:)];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        STESettings *settings = [STESettings shared];
        MenuItem *fontItem = [[MenuItem alloc] initWithSegment:@"小,中,大" image:[UIImage imageNamed:@"font_pop"] target:self action:@selector(fontChange:) defaultValue:settings.font];
        MenuItem *backgroundItem = [[MenuItem alloc] initWithSegment:@"白天,护眼,夜间" image:[UIImage imageNamed:@"scene_pop"] target:self action:@selector(backgroundChange:) defaultValue:settings.background];
        
        UIBarButtonItem *moreButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pop_navi"] style:UIBarButtonItemStyleDone target:self action: @selector(showMenu:)];
        
        //加载用户数据
        isFaultPrefer_setting = settings.isFaultPrefer;
        isLongPressFavor_setting = settings.isLongPressFavor;
        BOOL isShowAnswer_setting = settings.isShowAnswer;
        
        //数据初始化
        //displayIndexes = [NSMutableArray arrayWithArray:@[@"单", @"多", @"判"]];
        displaySections = [NSMutableArray arrayWithArray:@[@"一、单选题", @"二、多选题", @"三、判断题"]];
        displayQuestions = [NSMutableArray array];
        historyQuestions = [NSMutableArray array];
        questionStates = [NSMutableArray array];
        questionNumbers = [NSMutableArray array];
        for (NSString *index in displaySections) {
            [displayQuestions addObject:[NSMutableArray array]];
            [historyQuestions addObject:[NSMutableArray array]];
            [questionStates addObject:[NSMutableArray array]];
            [questionNumbers addObject:[NSMutableArray array]];
        }
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSError *error;
        
        //历史记录
        if (isHistory) {
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kHistoryQuestion];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(history_id = %@)", [history valueForKey:@"id"]];
            [request setPredicate:pred];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"question_number" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
            [request setSortDescriptors:sortDescriptors];
            NSArray *history_questions = [context executeFetchRequest:request error:&error];
            //仅显示错题
            if (isShowFault && isSubmit) {
                dispatch_async(dispatch_get_main_queue(),^{
                    popMenu = [[PopupMenu alloc] initWithItems:@[fontItem, backgroundItem]];
                    [self.navigationItem setRightBarButtonItems:@[moreButton]];
                });
                
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
                            [questionNumbers[[[question valueForKey:@"type"] integerValue] - 1] addObject:[history_question valueForKey:@"question_number"]];
                            [questionStates[[[question valueForKey:@"type"] integerValue] - 1] addObject:[NSNumber numberWithInteger:STEQuestionStateFault]];
                        }
                    }
                }
            } else {
                if (isSubmit) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        popMenu = [[PopupMenu alloc] initWithItems:@[fontItem, backgroundItem]];
                        [self.navigationItem setRightBarButtonItems:@[moreButton, nextFaultButton]];
                    });
                    
                } else {
                    if (isExam) {
                        dispatch_async(dispatch_get_main_queue(),^{
                            popMenu = [[PopupMenu alloc] initWithItems:@[submitItem, fontItem, backgroundItem]];
                            [self.navigationItem setRightBarButtonItems:@[moreButton, nextUndoButton]];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(),^{
                            popMenu = [[PopupMenu alloc] initWithItems:@[submitItem, showAnswerItem, fontItem, backgroundItem]];
                            [self.navigationItem setRightBarButtonItems:@[moreButton, nextUndoButton]];
                        });
                    }
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
                        [questionNumbers[[[question valueForKey:@"type"] integerValue] - 1] addObject:[history_question valueForKey:@"question_number"]];
                        if (isSubmit) {
                            if (![[history_question valueForKey:@"correct"] boolValue]){
                                [questionStates[[[question valueForKey:@"type"] integerValue] - 1] addObject:[NSNumber numberWithInteger:STEQuestionStateFault]];
                            } else {
                                [questionStates[[[question valueForKey:@"type"] integerValue] - 1] addObject:[NSNumber numberWithInteger:STEQuestionStateRight]];
                            }
                        } else {
                            BOOL isDo = NO;
                            for (int j = 1; j <= 4; j++) {
                                isDo = isDo | [[history_question valueForKey:[NSString stringWithFormat:@"choose%d", j]] boolValue];
                            }
                            if (isDo) {
                                [questionStates[[[question valueForKey:@"type"] integerValue] - 1] addObject:[NSNumber numberWithInteger:STEQuestionStateDone]];
                            } else {
                                [questionStates[[[question valueForKey:@"type"] integerValue] - 1] addObject:[NSNumber numberWithInteger:STEQuestionStateUndo]];
                            }
                        }
                    }
                }
            }
        }
        //非历史记录
        else {
            //刷题
            if (!isExam) {
                //默认显示答案
                if (isShowAnswer_setting) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        popMenu = [[PopupMenu alloc] initWithItems:@[fontItem, backgroundItem]];
                        [self.navigationItem setRightBarButtonItems:@[moreButton]];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(),^{
                        popMenu = [[PopupMenu alloc] initWithItems:@[submitItem, showAnswerItem, fontItem, backgroundItem]];
                        [self.navigationItem setRightBarButtonItems:@[moreButton, nextUndoButton]];
                    });
                    
                }
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"(section_id = %@)", [sections[0] valueForKey:@"id"]];
                [request setPredicate:pred];
                NSMutableArray *questions = [[context executeFetchRequest:request error:&error] mutableCopy];
                [self shuffle:questions];
                for (NSManagedObject *question in questions) {
                    [displayQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:question];
                }
            }
            //智能出题
            else {
                dispatch_async(dispatch_get_main_queue(),^{
                    popMenu = [[PopupMenu alloc] initWithItems:@[submitItem, fontItem, backgroundItem]];
                    [self.navigationItem setRightBarButtonItems:@[moreButton, nextUndoButton]];
                });
                NSMutableArray *tempQuestions = [NSMutableArray array];
                for (NSString *index in displaySections) {
                    [tempQuestions addObject:[NSMutableArray array]];
                }
                for (NSManagedObject *section in sections) {
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kQuestion];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(section_id = %@)", [section valueForKey:@"id"]];
                    [request setPredicate:pred];
                    NSArray *questions = [context executeFetchRequest:request error:&error];
                    if (questions != nil) {
                        for (NSManagedObject *question in questions) {
                            [tempQuestions[[[question valueForKey:@"type"] integerValue] - 1] addObject:question];
                        }
                    }
                }
                int i = 0;
                for (NSString *index in displaySections) {
                    displayQuestions[i] = [self generateQuestion:tempQuestions[i] withQuestionNum:60 andFaultPrefer:isFaultPrefer_setting];
                    i++;
                }
            }
            //默不显示答案
            if (!isExam && isShowAnswer_setting) {
                isShowAnswer = YES;
                int question_index = 0;
                int section_index = 0;
                for (NSArray *question_section in displayQuestions) {
                    for (NSManagedObject *question in question_section) {
                        [questionNumbers[section_index] addObject:[NSNumber numberWithInt:(question_index + 1)]];
                        [questionStates[section_index] addObject:[NSNumber numberWithInteger:STEQuestionStateUndo]];
                        question_index++;
                    }
                    section_index++;
                }
            } else {
                //初始化历史
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
                [history setValue:[NSNumber numberWithBool:isExam] forKey:@"isExam"];
                if (!isExam) {
                    [history setValue:[sections[0] valueForKey:@"name"] forKey:@"section_name"];
                }
                [history setValue:[NSNumber numberWithBool:NO] forKey:@"isSubmit"];
                
                //初始化历史详细记录
                NSFetchRequest *history_question_request = [[NSFetchRequest alloc] initWithEntityName:kHistoryQuestion];
                NSPredicate *history_question_pred = [NSPredicate predicateWithFormat:@"(history_id = %d)", history_id];
                [history_question_request setPredicate:history_question_pred];
                NSArray *history_questiones = [context executeFetchRequest:history_question_request error:&error];
                for (NSManagedObject *history_question in history_questiones) {
                    [context deleteObject:history_question];
                }
                int question_index = 0;
                int section_index = 0;
                for (NSArray *question_section in displayQuestions) {
                    for (NSManagedObject *question in question_section) {
                        NSManagedObject *history_question = [NSEntityDescription insertNewObjectForEntityForName:kHistoryQuestion inManagedObjectContext:context];
                        [history_question setValue:[NSNumber numberWithInt:history_id] forKey:@"history_id"];
                        [history_question setValue:[question valueForKey:@"id"] forKey:@"question_id"];
                        [history_question setValue:[NSNumber numberWithInt:(history_id * 1000 + question_index)] forKey:@"id"];
                        [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose1"];
                        [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose2"];
                        [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose3"];
                        [history_question setValue:[NSNumber numberWithBool:NO] forKey:@"choose4"];
                        [history_question setValue:[NSNumber numberWithInt:(question_index + 1)] forKey:@"question_number"];
                        [historyQuestions[section_index] addObject:history_question];
                        [questionNumbers[section_index] addObject:[NSNumber numberWithInt:(question_index + 1)]];
                        [questionStates[section_index] addObject:[NSNumber numberWithInteger:STEQuestionStateUndo]];
                        question_index++;
                    }
                    section_index++;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in [self.tableView.tableFooterView subviews]) {
                if ([subview class] == [UIActivityIndicatorView class]) {
                    [(UIActivityIndicatorView *)subview stopAnimating];
                }
            }
            //表头
            if (!isExam) {
                CGRect frameRect = CGRectMake(0, 0, self.tableView.frame.size.width - 20, 30);
                UIView *header = [[UIView alloc] initWithFrame:frameRect];
                CGRect label_rect = CGRectMake(0, 0, self.tableView.frame.size.width, 20);
                UILabel *label = [[UILabel alloc] initWithFrame:label_rect];
                label.tag = 99;
                label.font = [UIFont systemFontOfSize:13];
                label.textAlignment = NSTextAlignmentCenter;
                if (isHistory) {
                    label.text= [history valueForKey:@"section_name"];
                } else{
                    label.text= [sections[0] valueForKey:@"name"];
                }
                [header addSubview:label];
                self.tableView.tableHeaderView = header;
            }
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(),^{
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            });
            CGRect frame = (CGRect) {self.tableView.frame.size.width, self.navigationController.navigationBar.frame.size.height + 20 + 80, 0, self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - 80 * 2};
            self.asView = [[AnswerSheetView alloc] initWithQuestions:questionNumbers sections:displaySections states:questionStates frame:frame target:self performSelector:@selector(stepToQuestion:)];
            [self.navigationController.view addSubview:asView];
        });
    });
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"viewWillAppear");
    [self changeSetting];
//    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //NSLog(@"viewWillDisappear");
    asView.hidden = YES;
    [popMenu dismissMenu];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //NSLog(@"viewDidAppear");
    asView.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //NSLog(@"viewDidDisappear");
    if (!isSubmit) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if (![history isFault]) {
            [history setValue:[NSDate date] forKey:@"date"];
        }
        [appDelegate saveContext];
    }
    [asView dismissView];
    asView = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stepToQuestion:(NSNumber *)location
{
    long location_i = [location integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(location_i / 100) inSection:(location_i % 100)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 500ull * NSEC_PER_MSEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(location_i / 100) inSection:(location_i % 100)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    });
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
        
        CGFloat tipsWidth = 80.f;
        CGFloat tipsHeight = 40.f;
        CGRect tipsViewFrame = (CGRect){(self.tableView.frame.size.width - tipsWidth) / 2, (self.navigationController.view.frame.size.height + 20 + self.navigationController.navigationBar.frame.size.height - tipsHeight) / 2, tipsWidth, tipsHeight};
        UILabel *tips = [[UILabel alloc] initWithFrame:tipsViewFrame];
        tips.textColor = [UIColor whiteColor];
        tips.backgroundColor = cell.defaultTextColor;
        tips.textAlignment = NSTextAlignmentCenter;
        tips.alpha = 0.7f;
        if([[object valueForKey:@"isFavorite"] boolValue]){
            tips.text = @"已收藏";
        } else {
            tips.text = @"已取消";
        }
        [self.navigationController.view addSubview:tips];
        [UIView animateWithDuration:2 animations:^{
            tips.alpha = 0.0f;
        } completion:^(BOOL finished){
            [tips removeFromSuperview];
        }];
        
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
    
    CGFloat tipsWidth = 80.f;
    CGFloat tipsHeight = 40.f;
    CGRect tipsViewFrame = (CGRect){(self.tableView.frame.size.width - tipsWidth) / 2, (self.navigationController.view.frame.size.height + 20 + self.navigationController.navigationBar.frame.size.height - tipsHeight) / 2, tipsWidth, tipsHeight};
    UILabel *tips = [[UILabel alloc] initWithFrame:tipsViewFrame];
    tips.textColor = [UIColor whiteColor];
    tips.backgroundColor = cell.defaultTextColor;
    tips.textAlignment = NSTextAlignmentCenter;
    tips.alpha = 0.7f;
    if([[object valueForKey:@"isFavorite"] boolValue]){
        tips.text = @"已收藏";
    } else {
        tips.text = @"已取消";
    }
    [self.navigationController.view addSubview:tips];
    [UIView animateWithDuration:2 animations:^{
        tips.alpha = 0.0f;
    } completion:^(BOOL finished){
        [tips removeFromSuperview];
    }];
    
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
    NSString *chooseId = [NSString stringWithFormat:@"choose%ld", (long)choice.tag];
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
    BOOL isDo = NO;
    for (int j = 1; j <= 4; j++) {
        isDo = isDo | [[history_object valueForKey:[NSString stringWithFormat:@"choose%d", j]] boolValue];
    }
    if (isDo) {
        [self.questionStates[indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:STEQuestionStateDone]];
        [[NSNotificationCenter defaultCenter] postNotificationName:nQuestionState object:nil userInfo:@{@"state": [NSNumber numberWithInteger:STEQuestionStateDone], @"indexPath": indexPath}];
    } else {
        [self.questionStates[indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInteger:STEQuestionStateUndo]];
        [[NSNotificationCenter defaultCenter] postNotificationName:nQuestionState object:nil userInfo:@{@"state": [NSNumber numberWithInteger:STEQuestionStateUndo], @"indexPath": indexPath}];
    }
    [self.tableView reloadData];
    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    [cell refreshBackgroundAndFont];
    
    NSManagedObject *object = displayQuestions[indexPath.section][indexPath.row];
    NSManagedObject *history_question;
    if (!isShowAnswer) {
        history_question = historyQuestions[indexPath.section][indexPath.row];
    }
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
                NSString *correct_sign = @"✓";
                if (![(NSString *)[object valueForKey:@"answer"] containsString:choice_head[i - 1]]) {
                    correct_sign = @"　";
                }
                NSMutableAttributedString *choice_str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@. %@", correct_sign, choice_head[i - 1], [object valueForKey:choiceId]]];
                [choice_str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
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
        cell.analysis.text = ([object valueForKey:@"analysis"]) ? [NSString stringWithFormat:@"【答案】%@\n【解析】%@", [object valueForKey:@"answer"], [object valueForKey:@"analysis"]] : [NSString stringWithFormat:@"【答案】%@", [object valueForKey:@"answer"]];
    } else if(isSubmit) {
        cell.content.text = [NSString stringWithFormat:@"%ld. %@", (long)[[history_question valueForKey:@"question_number"] integerValue], [object valueForKey:@"content"]];
        
        for (int i = 1; i <= 4; i++) {
            NSString *choiceId = [NSString stringWithFormat:@"choice%d", i];
            NSString *chooseId = [NSString stringWithFormat:@"choose%d", i];
            UILabel *choice = (UILabel *)[cell viewWithTag:i];
            if ([[history_question valueForKey:chooseId] boolValue]) {
                choice.textColor = [UIColor blueColor];
            } else {
                choice.textColor = cell.defaultTextColor;
            }
            if ([object valueForKey:choiceId]) {
                BOOL isRight = YES;
                NSString *correct_sign = @"✓";
                if (![(NSString *)[object valueForKey:@"answer"] containsString:choice_head[i - 1]]) {
                    correct_sign = @"　";
                    isRight = NO;
                }
                NSMutableAttributedString *choice_str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@. %@", correct_sign, choice_head[i - 1], [object valueForKey:choiceId]]];
                if (isRight) {
                    [choice_str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
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
            cell.analysis.textColor = [UIColor blueColor];
        }
        cell.analysis.text = ([object valueForKey:@"analysis"]) ? [NSString stringWithFormat:@"【答案】%@\n【解析】%@", [object valueForKey:@"answer"], [object valueForKey:@"analysis"]] : [NSString stringWithFormat:@"【答案】%@", [object valueForKey:@"answer"]];
    } else {
        cell.content.text = [NSString stringWithFormat:@"%ld. %@", (long)[[history_question valueForKey:@"question_number"] integerValue], [object valueForKey:@"content"]];
        
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
                    choice.textColor = cell.defaultTextColor;
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

    if (isLongPressFavor_setting) {
        if ([[cell gestureRecognizers] count] == 0) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
            [cell addGestureRecognizer:longPress];
        }
    }
    
    
    if ([[cell.favoriteImage gestureRecognizers] count] == 0) {
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [cell.favoriteImage addGestureRecognizer:imageTap];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return displaySections[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    return displayIndexes;
//}

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
