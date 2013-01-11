//
//  NSTask+GOGit.m
//  DevBot
//
//  Created by Doug Russell on 1/10/13.
//

#import "NSTask+DVBTasks.h"

@implementation NSTask (DVBTasks)

const int DVBTaskSucessCode = 0;
static NSString *const xcrunPath = @"/usr/bin/xcrun";
static NSString *const xcodeBuildPath = @"/usr/bin/xcodebuild";

+ (instancetype)newTaskForPath:(NSString *)path
{
	NSParameterAssert(path);
	if (![[NSURL fileURLWithPath:path] checkResourceIsReachableAndReturnError:nil]){
		return nil;
    }
	NSTask *gitTask = [NSTask new];
    [gitTask setLaunchPath:path];
	return gitTask;
}

+ (instancetype)newXCRunTask
{
	return [self newTaskForPath:xcrunPath];
}

+ (instancetype)newXCodeBuildTask
{
	return [self newTaskForPath:xcodeBuildPath];
}

@end
