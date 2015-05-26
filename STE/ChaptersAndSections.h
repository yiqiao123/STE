//
//  ChaptersAndSections.h
//  STE
//
//  Created by 易乔 on 15/5/26.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface ChaptersAndSections : NSObject

+ (instancetype)shared;
- (NSArray *)allChapters;

- (NSArray *)sectionsWithChapterId:(NSNumber *)chapter_id;

- (NSManagedObject *)sectionWithId: (NSNumber *)section_id;

- (NSManagedObject *)chapterWithId: (NSNumber *)chapter_id;

@end
