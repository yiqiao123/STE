//
//  AppDelegate.m
//  STE
//
//  Created by 易乔 on 15/5/5.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "AppDelegate.h"




@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize settings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    settings = [NSMutableDictionary dictionary];
    settings[@"font"] = @1;
    settings[@"background"] = @0;
    settings[@"isShowAnswer"] = [NSNumber numberWithBool:NO];
    settings[@"isLongPressFavor"] = [NSNumber numberWithBool:YES];
    settings[@"isFaultPrefer"] = [NSNumber numberWithBool:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"isFirstStart"] || [[defaults objectForKey:@"isFirstStart"] boolValue]) {
        //初始化数据库
        [self deleteAndRecreateStore];
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *plistURL = [bundle URLForResource:@"securities" withExtension:@"plist"];
        NSArray *chapters = [NSArray arrayWithContentsOfURL:plistURL];
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        int chapter_id = 1;
        for (NSDictionary *chapter in chapters) {
            int section_id = 1;
            NSManagedObject *theChapter = [NSEntityDescription insertNewObjectForEntityForName:kChapter inManagedObjectContext:context];
            [theChapter setValue:[NSNumber numberWithInt:chapter_id] forKey:@"id"];
            [theChapter setValue:[chapter objectForKey:@"chapter_name"] forKey:@"name"];
            for (NSDictionary *section in [chapter objectForKey:@"sections"]) {
                int question_id = 1;
                NSManagedObject *theSection = [NSEntityDescription insertNewObjectForEntityForName:kSection inManagedObjectContext:context];
                [theSection setValue:[NSNumber numberWithInt:chapter_id] forKey:@"chapter_id"];
                [theSection setValue:[NSNumber numberWithInt:chapter_id * 100 + section_id] forKey:@"id"];
                [theSection setValue:[section objectForKey:@"section_name"] forKey:@"name"];
                for (NSDictionary *question in [section objectForKey:@"questions"]) {
                    NSManagedObject *theQuestion = [NSEntityDescription insertNewObjectForEntityForName:kQuestion inManagedObjectContext:context];
                    [theQuestion setValue:[NSNumber numberWithInt:chapter_id * 100 + section_id] forKey:@"section_id"];
                    [theQuestion setValue:[NSNumber numberWithInt:(chapter_id * 100 + section_id) * 1000 + question_id] forKey:@"id"];
                    [theQuestion setValue:[NSNumber numberWithInteger:[[question objectForKey:@"question_type"] integerValue]]forKey:@"type"];
                    [theQuestion setValue:[question objectForKey:@"question_content"] forKey:@"content"];
                    [theQuestion setValue:[question objectForKey:@"question_description"] forKey:@"analysis"];
                    [theQuestion setValue:[question objectForKey:@"question_answer"] forKey:@"answer"];
                    [theQuestion setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
                    int choice_id = 1;
                    for (NSString *choice in [question objectForKey:@"question_choice"]) {
                        [theQuestion setValue:choice forKey:[NSString stringWithFormat:@"choice%d", choice_id]];
                        choice_id++;
                    }
                    question_id++;
                }
                section_id++;
            }
            chapter_id++;
        }
        [self saveContext];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"isFirstStart"];
    }
    if (![defaults objectForKey:@"isShowAnswer"]) {
        [defaults setObject:settings[@"isShowAnswer"] forKey:@"isShowAnswer"];
    } else {
        settings[@"isShowAnswer"] = [defaults objectForKey:@"isShowAnswer"];
    }
    if (![defaults objectForKey:@"isLongPressFavor"]) {
        [defaults setObject:settings[@"isLongPressFavor"] forKey:@"isLongPressFavor"];
    } else {
        settings[@"isLongPressFavor"] = [defaults objectForKey:@"isLongPressFavor"];
    }
    if (![defaults objectForKey:@"isFaultPrefer"]) {
        [defaults setObject:settings[@"isFaultPrefer"] forKey:@"isFaultPrefer"];
    } else {
        settings[@"isFaultPrefer"] = [defaults objectForKey:@"isFaultPrefer"];
    }
    if (![defaults objectForKey:@"font"]) {
        [defaults setObject:settings[@"font"] forKey:@"font"];
    } else {
        settings[@"font"] = [defaults objectForKey:@"font"];
    }
    if (![defaults objectForKey:@"background"]) {
        [defaults setObject:settings[@"background"] forKey:@"background"];
    } else {
        settings[@"background"] = [defaults objectForKey:@"background"];
    }
    [defaults synchronize];
    
    NSLog(@"%@", NSHomeDirectory());
    extern CFAbsoluteTime StartTime;
    dispatch_async(dispatch_get_main_queue(), ^{
        printf("%f\n", StartTime);
        printf("%f\n", CFAbsoluteTimeGetCurrent());
        NSLog(@"Launched in %f sec", CFAbsoluteTimeGetCurrent() - StartTime);
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(void)deleteAndRecreateStore{
    NSPersistentStore * store = [[self.persistentStoreCoordinator persistentStores] lastObject];
    NSError * error;
    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:[store URL] error:&error];
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
    [self managedObjectContext];
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "yiqiao.ssss" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"STE" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"STE.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
