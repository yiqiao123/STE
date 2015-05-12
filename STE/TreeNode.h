//
//  TreeNode.h
//  STE
//
//  Created by 易乔 on 15/5/11.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject

@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) BOOL isExpand;

- (instancetype) initWithObject: (id)object andLevel: (NSInteger) node_level;
-(void) addChild: (TreeNode *) child;
-(void) removeChild: (TreeNode *) child;
-(BOOL) isLeaf;
-(id) value;
-(NSArray*) children;

@end
