//
//  STESettings.m
//  STE
//
//  Created by 易乔 on 15/7/18.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "STESettings.h"

@implementation STESettings

+ (instancetype)shared{
    static STESettings *sharedSTESettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSTESettings = [[self alloc] init];
    });
    return sharedSTESettings;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"isFirstStart"] != nil) {
            self.isFirstStart = [[defaults objectForKey:@"isFirstStart"] boolValue];
        } else {
            self.isFirstStart = YES;
        }
        if ([defaults objectForKey:@"isShowAnswer"] != nil) {
            self.isShowAnswer = [[defaults objectForKey:@"isShowAnswer"] boolValue];
        } else {
            self.isShowAnswer = NO;
        }
        if ([defaults objectForKey:@"isLongPressFavor"] != nil) {
            self.isLongPressFavor = [[defaults objectForKey:@"isLongPressFavor"] boolValue];
        } else {
            self.isLongPressFavor = YES;
        }
        if ([defaults objectForKey:@"isFaultPrefer"] != nil) {
            self.isFaultPrefer = [[defaults objectForKey:@"isFaultPrefer"] boolValue];
        } else {
            self.isFaultPrefer = YES;
        }
        if ([defaults objectForKey:@"font"] != nil) {
            self.font = [[defaults objectForKey:@"font"] integerValue];
        } else {
            self.font = STEFontSizeMiddle;
        }
        if ([defaults objectForKey:@"background"] != nil) {
            self.background = [[defaults objectForKey:@"background"] integerValue];
        } else {
            self.background = STEBackgroundStyleDefault;
        }
        self.navigationBarTintColor = [UIColor whiteColor];
        self.navigationBarStyle = UIBarStyleBlackTranslucent;
    }
    
    return self;
}

- (void)setFont: (STEFontSize)font{
    _font = font;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:font] forKey:@"font"];
    [defaults synchronize];
}
- (void)setBackground: (STEBackgroundStyle)background{
    _background = background;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:background] forKey:@"background"];
    if (background == STEBackgroundStyleDefault) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.textColor = [UIColor darkTextColor];
    } else if(background == STEBackgroundStyleGreen){
        self.backgroundColor = [UIColor colorWithRed:0.777 green:0.925 blue:0.8 alpha:1.0];
        self.textColor = [UIColor darkTextColor];
    } else if(background == STEBackgroundStyleDark){
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor lightTextColor];
    }
    [defaults synchronize];
}
- (void)setIsShowAnswer: (BOOL)isShowAnswer{
    _isShowAnswer = isShowAnswer;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:isShowAnswer] forKey:@"isShowAnswer"];
    [defaults synchronize];
}
- (void)setIsLongPressFavor: (BOOL)isLongPressFavor{
    _isLongPressFavor = isLongPressFavor;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:isLongPressFavor] forKey:@"isLongPressFavor"];
    [defaults synchronize];
}
- (void)setIsFaultPrefer: (BOOL)isFaultPrefer{
    _isFaultPrefer = isFaultPrefer;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:isFaultPrefer] forKey:@"isFaultPrefer"];
    [defaults synchronize];
}
- (void)setIsFirstStart: (BOOL)isFirstStart{
    _isFirstStart = isFirstStart;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:isFirstStart] forKey:@"isFirstStart"];
    [defaults synchronize];
}

@end
