//
//  NSTask+GOGit.h
//  DevBot
//
//  Created by Doug Russell on 1/10/13.
//

#import <Foundation/Foundation.h>

extern const int DVBTaskSucessCode;

@interface NSTask (DVBTasks)

+ (instancetype)newTaskForPath:(NSString *)path;
+ (instancetype)newXCRunTask;
+ (instancetype)newXCodeBuildTask;

@end
