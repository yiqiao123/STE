//
//  MenuView.m
//  STE
//
//  Created by 易乔 on 15/6/6.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "MenuView.h"

const static CGFloat kArrowSize = 8.f;

@interface MenuView ()

@property (strong, nonatomic) NSMutableArray *menuItems;
@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGPoint arrowPosition;

@end

@implementation MenuView
@synthesize menuItems;
@synthesize contentView;
@synthesize arrowPosition;

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.alpha = 0;
        menuItems = [NSMutableArray array];
        self.foreColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeMake(2, 2);
//        self.layer.shadowRadius = 2;
        [self initContentView];
    }
    
    return self;
}

- (id)initWithItems:(NSArray *)menuItems_l{
    self = [super initWithFrame:CGRectZero];
    if(self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.alpha = 0;
        menuItems = [menuItems_l mutableCopy];
        self.foreColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeMake(2, 2);
//        self.layer.shadowRadius = 2;
        [self initContentView];
    }
    
    return self;
}

- (void)performAction:(id)sender{
    [menuItems[((UIView *)sender).tag] performAction:sender];
}

- (void) showMenuInView:(UIView *)view fromRect:(CGRect)rect{
    if (contentView) {
        [self addSubview:contentView];
        CGFloat rectXMiddle = rect.origin.x + rect.size.width * 0.5f;
        CGFloat frameY = rect.origin.y + rect.size.height;
        arrowPosition.x = rectXMiddle;
        arrowPosition.y = frameY;
        CGFloat marginXToSuperview = 5.f;
        //最右
        if ((rectXMiddle + contentView.frame.size.width * 0.5f) > view.bounds.size.width) {
            self.frame = (CGRect){view.bounds.size.width - contentView.frame.size.width - marginXToSuperview, frameY, contentView.frame.size.width, contentView.frame.size.height + kArrowSize};
            contentView.frame = (CGRect){0, kArrowSize, contentView.frame.size};
        }
        //最左
        else if ((rectXMiddle - contentView.frame.size.width * 0.5f) < 0){
            self.frame = (CGRect){marginXToSuperview, frameY, contentView.frame.size.width, contentView.frame.size.height + kArrowSize};
            contentView.frame = (CGRect){0, kArrowSize, contentView.frame.size};
        } else {
            self.frame = (CGRect){rectXMiddle - contentView.frame.size.width * 0.5f, frameY, contentView.frame.size.width, contentView.frame.size.height + kArrowSize};
            contentView.frame = (CGRect){0, kArrowSize, contentView.frame.size};
        }
        arrowPosition.x = arrowPosition.x - self.frame.origin.x;
    }
    MenuOverlay *overlay = [[MenuOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    [self setNeedsDisplay];
    //contentView.hidden = YES;
    //CGRect toFrame = self.frame;
    //self.frame = (CGRect){arrowPosition, 1, 1};
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
        //self.frame = toFrame;
    } completion:^(BOOL finished){
        //contentView.hidden = NO;
    }];
    
}

-(void) initContentView {
    CGFloat itemYStart = 0;
    const CGFloat kMinHeight = 20.f;
    const CGFloat kMinWidth = 20.f;
    const CGFloat kMarginX = 10.f;
    const CGFloat kMarginY = 5.f;
    
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    CGFloat maxImageWidth= 0;
    CGFloat maxTitleWidth= 0;
    
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    if ([menuItems count] == 0) {
        contentView = nil;
    } else {
        contentView = [[UIView alloc] initWithFrame:CGRectZero];
        contentView.opaque = NO;
        contentView.backgroundColor = [UIColor clearColor];
        contentView.autoresizingMask = UIViewAutoresizingNone;
        
        UIFont *titleFont = [UIFont systemFontOfSize:17];
        for (MenuItem *menuItem in menuItems) {
            if (menuItem.image) {
                maxHeight = MAX(maxHeight, menuItem.image.size.height + 2 * kMarginY);
                maxImageWidth = MAX(maxImageWidth, menuItem.image.size.width);
            }
            if (menuItem.type == 0 || menuItem.type == 1) {
                CGSize titleSize = [menuItem.title sizeWithAttributes:@{NSFontAttributeName: titleFont}];
                maxTitleWidth = MAX(maxTitleWidth, titleSize.width);
                maxHeight = MAX(maxHeight, titleSize.height + 2 * kMarginY);
            } else if(menuItem.type == 2) {
                UISegmentedControl *temp = [[UISegmentedControl alloc] initWithItems:[menuItem.title componentsSeparatedByString:@","]];
                maxTitleWidth = MAX(maxTitleWidth, temp.frame.size.width);
                maxHeight = MAX(maxHeight, temp.frame.size.height + 2 * kMarginY);
            }
        }
        maxWidth = MAX(maxWidth, maxImageWidth + maxTitleWidth + 3 * kMarginX);
        maxHeight = MAX(maxHeight, kMinHeight);
        maxWidth = MAX(maxWidth, kMinWidth);
        
        int itemIndex = 0;
        
        UIImage *buttonSelectImage = [self linearImageWithSize:(CGSize){maxWidth, maxHeight} Color:[UIColor blackColor]];
        UIImage *splitLine = [self linearImageWithSize:(CGSize){maxWidth - 2 * kMarginX, 1} Color:[UIColor darkGrayColor]];
        
        for (MenuItem *menuItem in menuItems) {
            UIView *itemView = [[UIView alloc] initWithFrame:(CGRect){0, itemYStart, maxWidth, maxHeight}];
            itemView.autoresizingMask = UIViewAutoresizingNone;
            itemView.backgroundColor = [UIColor clearColor];
            itemView.opaque = NO;
            [contentView addSubview:itemView];
            
            if (menuItem.type == 1) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.tag = itemIndex;
                button.frame = itemView.bounds;
                button.backgroundColor = [UIColor clearColor];
                button.opaque = NO;
                button.autoresizingMask = UIViewAutoresizingNone;
                [button addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
                [button setBackgroundImage:buttonSelectImage forState:UIControlStateHighlighted];
                [itemView addSubview:button];
            }
            if (menuItem.image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){kMarginX, itemYStart + kMarginY, maxImageWidth, maxHeight - 2 * kMarginY}];
                imageView.image = menuItem.image;
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeCenter;
                imageView.autoresizingMask = UIViewAutoresizingNone;
                [contentView addSubview:imageView];
            }
            if (menuItem.title) {
                if (menuItem.type == 2) {
                    UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithFrame:(CGRect){kMarginX * 2 + maxImageWidth, itemYStart + kMarginY, maxTitleWidth, maxHeight - kMarginY * 2}];
                    NSArray *segmentItems = [menuItem.title componentsSeparatedByString:@","];
                    int index = 0;
                    for (NSString *item in segmentItems) {
                        [segmentControl insertSegmentWithTitle:item atIndex:index animated:NO];
                        index++;
                    }
                    segmentControl.tintColor = menuItem.foreColor ? menuItem.foreColor : [UIColor whiteColor];
                    segmentControl.tag = itemIndex;
                    segmentControl.autoresizingMask = UIViewAutoresizingNone;
                    segmentControl.opaque = NO;
                    segmentControl.backgroundColor = [UIColor clearColor];
                    [segmentControl setSelectedSegmentIndex:menuItem.value];
                    [segmentControl addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventValueChanged];
                    [contentView addSubview:segmentControl];
                    
                } else {
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){kMarginX * 2 + maxImageWidth, kMarginY, maxTitleWidth, maxHeight - kMarginY * 2}];
                    titleLabel.text = menuItem.title;
                    titleLabel.font = titleFont;
                    titleLabel.textAlignment = menuItem.alignment;
                    titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.autoresizingMask = UIViewAutoresizingNone;
                    [itemView addSubview:titleLabel];
                }
            }
            itemYStart += maxHeight;
            if (itemIndex < [menuItems count] - 1) {
                UIImageView *line = [[UIImageView alloc] initWithFrame:(CGRect){kMarginX, itemYStart, maxWidth - 2 * kMarginX, 1}];
                line.image = splitLine;
                [contentView addSubview:line];
                itemYStart += 1;
            }
            itemIndex++;
        }
    }
    contentView.frame = (CGRect){0, 0, maxWidth, itemYStart};
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

- (void) dismissMenu{
    if ([self.superview isKindOfClass:[MenuOverlay class]]) {
        [self.superview removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void) addMenuItem:(MenuItem *)menuItem_l{
    [self.menuItems addObject:menuItem_l];
    [self initContentView];
    
}

- (void) deleteMenuItem: (MenuItem *)menuItem_l{
    [self.menuItems removeObject:menuItem_l];
    [self initContentView];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, arrowPosition.x, 0);
    CGContextAddLineToPoint(context, arrowPosition.x - kArrowSize, kArrowSize);
    CGContextAddLineToPoint(context, arrowPosition.x + kArrowSize, kArrowSize);
    CGContextAddLineToPoint(context, arrowPosition.x, 0);
    CGContextAddRect(context, (CGRect){0, kArrowSize, self.bounds.size.width, self.bounds.size.height - kArrowSize});
    CGContextSetFillColorWithColor(context, self.foreColor.CGColor);
    CGContextFillPath(context);
}


@end
