//
//  NSString+DVBFileTypes.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//

#import <Foundation/Foundation.h>

@interface NSString (DVBFileTypes)
- (BOOL)isPathToAppFile;
- (BOOL)isPathToDSYMFile;
@end
