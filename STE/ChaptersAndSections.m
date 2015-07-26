//
//  ChaptersAndSections.m
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "ChaptersAndSections.h"
#import "AppDelegate.h"

@interface ChaptersAndSections()
@property (strong, nonatomic) NSMutableDictionary *chapters;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSMutableDictionary *chapterToSection;

@end

@implementation ChaptersAndSections
@synthesize chapters;
@synthesize sections;
@synthesize chapterToSection;

+ (instancetype)shared{
    static ChaptersAndSections *sharedChaptersAndSections = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChaptersAndSections = [[self alloc] init];
    });
    return sharedChaptersAndSections;
}

- (instancetype)init{
    self = [super init];
    chapters = [NSMutableDictionary dictionary];
    sections = [NSMutableDictionary dictionary];
    chapterToSection = [NSMutableDictionary dictionary];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kChapter];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    [request setSortDescriptors:sortDescriptors];
    NSArray *chapters_mo = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *chapter_mo in chapters_mo) {
        id chapter_id = [chapter_mo valueForKey:@"id"];
        [chapters setObject:chapter_mo forKey:chapter_id];
        NSFetchRequest *section_request = [[NSFetchRequest alloc] initWithEntityName:kSection];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(chapter_id = %@)", chapter_id];
        [section_request setPredicate:pred];
        [section_request setSortDescriptors:sortDescriptors];
        NSArray *sections_mo = [context executeFetchRequest:section_request error:&error];
        if ([sections_mo count] > 0) {
            NSMutableArray *sections_id = [NSMutableArray array];
            [chapterToSection setObject:sections_id forKey:[chapter_mo valueForKey:@"id"]];
            for (NSManagedObject *section_mo in sections_mo) {
                [sections setValue:section_mo forKey:[section_mo valueForKey:@"id"]];
                [(NSMutableArray *)[chapterToSection objectForKey:chapter_id] addObject:[section_mo valueForKey:@"id"]];
            }
        }
    }
    
    return self;
}

- (NSArray *)allChapters{
    NSMutableArray *all_chapters = [NSMutableArray array];
    NSArray *keys = [chapters allKeys];
    keys = [keys sortedArrayUsingComparator:^(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    for (NSNumber *chapter_id in keys) {
        [all_chapters addObject:[chapters objectForKey:chapter_id]];
    }
    return all_chapters;
}

- (NSArray *)sectionsWithChapterId:(NSNumber *)chapter_id{
    NSMutableArray *sectionsWithChapterId = [NSMutableArray array];
    for (NSNumber *sections_id in [chapterToSection objectForKey:chapter_id]) {
        [sectionsWithChapterId addObject:[sections objectForKey:sections_id]];
    }
    return sectionsWithChapterId;
}

- (NSManagedObject *)sectionWithId: (NSNumber *)section_id{
    return [sections objectForKey:section_id];
}

- (NSManagedObject *)chapterWithId: (NSNumber *)chapter_id{
    return [chapters objectForKey:chapter_id];
}

@end
