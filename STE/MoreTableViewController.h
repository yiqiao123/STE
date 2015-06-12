//
//  MoreTableViewController.h
//  STE
//
//  Created by 易乔 on 15/5/31.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryTableViewController.h"
#import "AppDelegate.h"
#import "MoreSegmentTableViewCell.h"
#import "MoreSwitchTableViewCell.h"

@interface MoreTableViewController : UITableViewController
- (IBAction)segmentChanged:(id)sender;

- (IBAction)switchChanged:(id)sender;

@end
