//
//  NSString+DVBFileTypes.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DVBFileTypes)
- (BOOL)isPathToAppFile;
- (BOOL)isPathToDSYMFile;
@end
