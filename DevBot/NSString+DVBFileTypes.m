//
//  NSString+DVBFileTypes.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//

#import "NSString+DVBFileTypes.h"

@implementation NSString (DVBFileTypes)

- (BOOL)isPathToAppFile
{
    return [[self lastPathComponent] hasSuffix:@".app"];
}

- (BOOL)isPathToDSYMFile
{
    return [[self lastPathComponent] hasSuffix:@".dSYM"];
}

@end
