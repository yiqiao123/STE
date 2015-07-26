//
//  AnswerSheetView.m
//  STE
//
//  Created by 易乔 on 15/7/19.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "AnswerSheetView.h"
#import "QuestionTableViewController.h"

@interface AnswerSheetView()

@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL selector;
//每一次panGesture之前的记录
@property (assign, nonatomic) CGPoint lastCenterPoint;
@property (assign, nonatomic) CGFloat lastAlpha;
//panGesture每次变动时的记录
@property (assign, nonatomic) CGPoint lastPoint;
//@property (assign, nonatomic) CGFloat scrollVelocity;
//@property (assign, nonatomic) double lastTime;

@property (assign, nonatomic) STEPanGestureDirection direction;

@property (assign, nonatomic) CGPoint rightCenterPoint;
@property (assign, nonatomic) CGPoint leftCenterPoint;
@property (strong, nonatomic) UIScrollView *answerView;

@property (strong, nonatomic) UIColor *backgroundViewColor;
@property (strong, nonatomic) UIColor *buttonUndoColor;
@property (strong, nonatomic) UIColor *buttonDoneColor;
@property (strong, nonatomic) UIColor *buttonFaultColor;
@property (strong, nonatomic) UIColor *buttonRightColor;
@property (strong, nonatomic) UIColor *buttonTextColor;
@property (strong, nonatomic) UIColor *textColor;


@end

@implementation AnswerSheetView
- (instancetype)initWithQuestions:(NSMutableArray *)questions sections:(NSMutableArray *)sections states:(NSMutableArray *)states frame:(CGRect)frame target:(id)target performSelector:(SEL)selector
{
    float leftWidth = 13.0f;
    float xMargin = 8.0f;
    float yMargin = 8.0f;
    
    float labelHeight = 21.0f;
    float labelWidth = 100.0f;
    float buttonWidth = 50.0f;
    float buttonHeight = 50.0f;
    int buttonNumerInLine = 3;
    
    float xIndex = 0.0f;
    float yIndex = 0.0f;
    
    self.backgroundViewColor = [UIColor lightGrayColor];
    self.buttonUndoColor = [UIColor whiteColor];
    self.buttonDoneColor = [UIColor blueColor];
    self.buttonFaultColor = [UIColor redColor];
    self.buttonRightColor = [UIColor blueColor];
    self.buttonTextColor = [UIColor lightGrayColor];
    self.textColor = [UIColor darkTextColor];
    
    float contentWidth = xMargin * (buttonNumerInLine + 1) + buttonWidth * buttonNumerInLine;
    float width = leftWidth + contentWidth + frame.origin.x;
    frame.size.width = width;
    frame.origin.x = frame.origin.x - leftWidth;
    
    self = [super initWithFrame:frame];
    if(self) {
        self.target = target;
        self.selector = selector;
        
        self.backgroundColor = self.backgroundViewColor;
        self.opaque = NO;
        self.alpha = minAlpha;
        self.tag = -1;
        [self.layer setCornerRadius:10.0];
        
        float titleHeight = 20.0f;
        float titleMargin = 40.0f;
        UILabel *label1 = [[UILabel alloc] initWithFrame:(CGRect){0, (frame.size.height - titleHeight) / 2 - titleMargin, leftWidth, titleHeight}];
        label1.text = @"答";
        label1.font = [UIFont systemFontOfSize:13];
        label1.textColor = self.textColor;
        label1.tag = -3;
        [self addSubview:label1];
        UILabel *label2 = [[UILabel alloc] initWithFrame:(CGRect){0, (frame.size.height - titleHeight) / 2, leftWidth, titleHeight}];
        label2.text = @"题";
        label2.font = [UIFont systemFontOfSize:13];
        label2.textColor = self.textColor;
        label2.tag = -4;
        [self addSubview:label2];
        UILabel *label3 = [[UILabel alloc] initWithFrame:(CGRect){0, (frame.size.height - titleHeight) / 2 + titleMargin, leftWidth, titleHeight}];
        label3.text = @"卡";
        label3.font = [UIFont systemFontOfSize:13];
        label3.textColor = self.textColor;
        label3.tag = -5;
        [self addSubview:label3];
        
        CGRect scrollFrame =  (CGRect){leftWidth, yMargin, contentWidth, frame.size.height - 2*yMargin};
        self.answerView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        self.answerView.backgroundColor = [UIColor clearColor];
        self.answerView.opaque = NO;
        self.answerView.tag = -2;
        [self addSubview: self.answerView];
        
        UIImage *buttonBackground = [self linearImageWithSize:(CGSize){buttonWidth, buttonHeight} Color:self.backgroundViewColor];
        for (int i = 0; i < [questions count]; i++) {
            yIndex += yMargin;
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){xMargin, yIndex, labelWidth, labelHeight}];
            label.tag = -6 - i;
            label.text = sections[i];
            label.textColor = self.textColor;
            yIndex += labelHeight;
            [self.answerView addSubview:label];
            for (int j = 0; j < [questions[i] count]; j++) {
                if (j % buttonNumerInLine == 0) {
                    xIndex = 0;
                    yIndex += yMargin;
                }
                xIndex += xMargin;
                UIButton *button = [[UIButton alloc] initWithFrame:(CGRect){xIndex, yIndex, buttonWidth, buttonHeight}];
                
                button.tag = j * 100 + i;
                [button.layer setMasksToBounds:YES];
                [button.layer setCornerRadius:10.0];
                if ([states[i][j] integerValue] == STEQuestionStateUndo) {
                    [button setBackgroundColor:self.buttonUndoColor];
                } else if ([states[i][j] integerValue] == STEQuestionStateDone) {
                    [button setBackgroundColor:self.buttonDoneColor];
                } else if ([states[i][j] integerValue] == STEQuestionStateRight) {
                    [button setBackgroundColor:self.buttonRightColor];
                } else if ([states[i][j] integerValue] == STEQuestionStateFault) {
                    [button setBackgroundColor:self.buttonFaultColor];
                }
                [button setBackgroundImage:buttonBackground forState:UIControlStateHighlighted];
                
                [button setTitle:[questions[i][j] stringValue] forState:UIControlStateNormal];
                [button setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
                [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
                [self.answerView addSubview:button];
                
                xIndex += buttonWidth;
                if (j % buttonNumerInLine == (buttonNumerInLine - 1) || j == ([questions[i] count] - 1)) {
                    yIndex += buttonHeight;
                }
                
            }
        }
        yIndex += yMargin;
        [self.answerView setContentSize:(CGSize){0, yIndex}];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeState:) name:nQuestionState object:nil];
        
        UIPanGestureRecognizer *panGesture =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        panGesture.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self addGestureRecognizer:tapGesture];
        
        self.rightCenterPoint = self.center;
        self.leftCenterPoint = (CGPoint){self.center.x - contentWidth, self.center.y};
    }
    
    return self;
}

- (void)tapView:(UITapGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.center.x == self.rightCenterPoint.x) {
            [self showAnswerView];
        }
    }
}

- (void)panView:(UIPanGestureRecognizer *)recognizer{
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        self.lastCenterPoint = self.center;
        self.lastAlpha = self.alpha;
        self.lastPoint = [recognizer locationInView:[self superview]];
        //self.scrollVelocity = 0.0f;
        //self.lastTime = [NSDate timeIntervalSinceReferenceDate];
    } else if([recognizer state] == UIGestureRecognizerStateChanged){
        if (self.direction == STEPanGestureDirectionNone) {
            if (ABS([recognizer locationInView:[self superview]].x - self.lastPoint.x) < ABS([recognizer locationInView:[self superview]].y - self.lastPoint.y)){
                self.direction = STEPanGestureDirectionVertical;
            } else {
                self.direction = STEPanGestureDirectionHorizontal;
            }
        }
        if(self.direction == STEPanGestureDirectionHorizontal){
            //double nowTime = [NSDate timeIntervalSinceReferenceDate];
            //NSLog(@"change location: %f", [recognizer locationInView:[self superview]].x);
            CGPoint now = self.center;
            now.x += [recognizer locationInView:[self superview]].x - self.lastPoint.x;
            self.center = now;
            //self.scrollVelocity = ([recognizer locationInView:[self superview]].x - self.lastPoint.x) / (nowTime - self.lastTime);
            self.lastPoint = [recognizer locationInView:[self superview]];
            //self.lastTime = nowTime;
            if (self.center.x < self.leftCenterPoint.x) {
                self.alpha = maxAlpha;
            } else if(self.center.x > self.rightCenterPoint.x){
                self.alpha = minAlpha;
            } else{
                self.alpha = maxAlpha - (self.center.x - self.leftCenterPoint.x)/(self.rightCenterPoint.x - self.leftCenterPoint.x) * (maxAlpha - minAlpha);
            }
            
        } else if(self.direction == STEPanGestureDirectionVertical){
//            CGPoint now = self.contentOffset;
//            now.y -= [recognizer locationInView:[self superview]].y - self.lastPoint.y;
//            self.contentOffset = now;
//            self.lastPoint = [recognizer locationInView:[self superview]];
        }
        
    } else if([recognizer state] == UIGestureRecognizerStateEnded){
        if(self.direction == STEPanGestureDirectionHorizontal){
            //NSLog(@"end location: %f", [recognizer locationInView:[self superview]].x);
            //NSLog(@"speed %f", self.scrollVelocity);
            CGPoint now = self.center;
            now.x += [recognizer locationInView:[self superview]].x - self.lastPoint.x;
            self.center = now;
            if (self.center.x < self.leftCenterPoint.x) {
                self.alpha = maxAlpha;
            } else if(self.center.x > self.rightCenterPoint.x){
                self.alpha = minAlpha;
            } else{
                self.alpha = maxAlpha - (self.center.x - self.leftCenterPoint.x)/(self.rightCenterPoint.x - self.leftCenterPoint.x) * (maxAlpha - minAlpha);
            }
//            if (self.scrollVelocity > 800.0f) {
//                [self hideAnswerView];
//            } else if(self.scrollVelocity < -800.0f){
//                [self showAnswerView];
//            } else
            if((self.center.x - self.lastCenterPoint.x) > 50.0f){
                [self hideAnswerView];
            } else if((self.center.x - self.lastCenterPoint.x) < -50.0f){
                [self showAnswerView];
            } else{
                if (self.lastCenterPoint.x == self.rightCenterPoint.x) {
                    [self hideAnswerView];
                } else if(self.lastCenterPoint.x == self.leftCenterPoint.x){
                    [self showAnswerView];
                } else {
                    self.center = self.lastCenterPoint;
                    self.alpha = self.lastAlpha;
                }
            }
//            if (self.center.x > (self.rightCenterPoint.x + self.leftCenterPoint.x) / 2) {
//                [self hideAnswerView];
//            } else {
//                [self showAnswerView];
//            }
        } else if(self.direction == STEPanGestureDirectionVertical){
//            CGPoint now = self.contentOffset;
//            now.y -= [recognizer locationInView:[self superview]].y - self.lastPoint.y;
//            self.contentOffset = now;
//            if (self.contentOffset.y > self.contentSize.height - self.frame.size.height) {
//                [UIView animateWithDuration:0.5 animations:^{
//                    self.contentOffset = (CGPoint){0, self.contentSize.height - self.frame.size.height};
//                }];
//            } else if(self.contentOffset.y < 0) {
//                [UIView animateWithDuration:0.5 animations:^{
//                    self.contentOffset = (CGPoint){0, 0};
//                }];
//            }
        }
        self.direction = STEPanGestureDirectionNone;
    } else if([recognizer state] == UIGestureRecognizerStateCancelled){
        self.center = self.lastCenterPoint;
        self.alpha = self.lastAlpha;
        self.direction = STEPanGestureDirectionNone;
        //self.scrollVelocity = 0.0f;
        //self.lastTime = 0.0f;
    }

}

- (void)showAnswerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = maxAlpha;
            self.center = self.leftCenterPoint;
        }];
    });
}

- (void)hideAnswerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = minAlpha;
            self.center = self.rightCenterPoint;
        }];
    });
}


- (void)changeState:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSIndexPath *indexPath = (NSIndexPath *)userInfo[@"indexPath"];
    if (indexPath) {
        long tag = indexPath.row * 100 + indexPath.section;
        UIButton *button = (UIButton *)[self.answerView viewWithTag:tag];
        if (button) {
            if ([userInfo[@"state"] integerValue] == STEQuestionStateDone) {
                [button setBackgroundColor:self.buttonDoneColor];
            } else if ([userInfo[@"state"] integerValue] == STEQuestionStateUndo) {
                [button setBackgroundColor:self.buttonUndoColor];
            }
        }
    }
    
}

- (void)buttonTap: (UIButton *)sender
{
    if (self.target && [self.target respondsToSelector:self.selector]) {
        [self hideAnswerView];
        [self.target performSelector:self.selector withObject:[NSNumber numberWithInteger:sender.tag]];
    }
}

- (UIImage *)linearImageWithSize:(CGSize)size Color:(UIColor *)color{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, (CGRect){0, 0, size});
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  image;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissView{
    if (self.answerView) {
        [self.answerView removeFromSuperview];
    }
    [self removeFromSuperview];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
