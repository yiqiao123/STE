//
//  STESettings.h
//  STE
//
//  Created by 易乔 on 15/7/18.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STEBackgroundStyle) {
    STEBackgroundStyleDefault,
    STEBackgroundStyleGreen,
    STEBackgroundStyleDark
};

typedef NS_ENUM(NSInteger, STEFontSize) {
    STEFontSizeSmall,
    STEFontSizeMiddle,
    STEFontSizeBig
};

@interface STESettings : NSObject

@property (assign, nonatomic) STEFontSize font;
@property (assign, nonatomic) STEBackgroundStyle background;
@property (assign, nonatomic) BOOL isShowAnswer;
@property (assign, nonatomic) BOOL isLongPressFavor;
@property (assign, nonatomic) BOOL isFaultPrefer;
@property (assign, nonatomic) BOOL isFirstStart;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (assign, nonatomic) UIBarStyle navigationBarStyle;

+ (instancetype)shared;

@end
