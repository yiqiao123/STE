//
//  TreeNode.m
//  STE
//
//  Created by 易乔 on 15/5/11.
//  Copyright (c) 2015年 yiqiao. All rights reserved.
//

#import "TreeNode.h"
@interface TreeNode()

@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSMutableArray *children;
@property (assign, nonatomic) BOOL isLeaf;

@end


@implementation TreeNode

- (instancetype) initWithObject: (id)object andLevel: (NSInteger) node_level
{
    self = [super init];
    if (self) {
        _value = object;
        _children = [NSMutableArray array];
        _isExpand = NO;
        _isLeaf = YES;
        _level = node_level;
        _isSelected = NO;
    }
    return self;
}

-(void) addChild: (TreeNode *) child
{
    [_children addObject:child];
    _isLeaf = NO;
}

-(void) removeChild: (TreeNode *) child
{
    [_children removeObject:child];
    if ([_children count] == 0) {
        _isLeaf = YES;
    }
}

-(BOOL) isLeaf
{
    return _isLeaf;
}

-(NSArray*) children
{
    return [_children copy];
}

-(id) value
{
    return _value;
}

-(void) select{
    _isSelected = YES;
    for (TreeNode *child in _children) {
        [child select];
    }
}

-(void) unSelect{
    _isSelected = NO;
    for (TreeNode *child in _children) {
        [child unSelect];
    }
}

@end
