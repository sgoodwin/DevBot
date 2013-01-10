//
//  NSTask+GOGit.h
//  DevBot
//
//  Created by Doug Russell on 1/10/13.
//

#import <Foundation/Foundation.h>

@interface NSTask (GOGit)

+ (instancetype)newTaskForPath:(NSString *)path;
+ (instancetype)newXCRunTask;
+ (instancetype)newXCodeBuildTask;

@end
