//
//  AppDelegate.h
//  STE
//
//  Created by 易乔 on 15/5/5.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

static NSString * const kChapter = @"Chapter";
static NSString * const kSection = @"Section";
static NSString * const kQuestion = @"Question";
static NSString * const kHistory = @"History";
static NSString * const kHistoryQuestion = @"History_Question";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end

