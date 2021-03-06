//
//  GOGitCheckOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "DVBGitCheckOperation.h"

@interface DVBGitCheckOperation()
@property (nonatomic, strong) NSString *folderPath;
@end

@implementation DVBGitCheckOperation

- (id)initWithProjectPath:(NSString *)path
{
    self = [super init];
    if(self){
        self.folderPath = [path copy];
        self.executing = NO;
        self.finished = NO;
    }
    return self;
}

- (void)start
{
    self.executing = YES;
    
    if([self pullFromBranch:@"master"]){
        [self retrieveLatestRevision];
    }else{
        NSLog(@"Failed to pull to latest!");
    }
    
    self.executing = NO;
    self.finished = YES;
}

#pragma mark - Helpers

- (BOOL)pullFromBranch:(NSString *)branch
{
    NSTask *gitTask = [NSTask newXCRunTask];
    [gitTask setCurrentDirectoryPath:self.folderPath];
    [gitTask setArguments:@[@"git", @"pull", @"origin", branch]];
    
    NSPipe *pipe = [NSPipe pipe];
    [gitTask setStandardOutput:pipe];
    [gitTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [gitTask launch];
    
    NSData *data = [file readDataToEndOfFile];
    self.gitPullResults = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [gitTask waitUntilExit];
    
    BOOL worked = [gitTask terminationStatus] == DVBTaskSucessCode;
    return worked;
}

- (void)retrieveLatestRevision
{
    NSTask *gitTask = [NSTask newXCRunTask];
    [gitTask setCurrentDirectoryPath:self.folderPath];
    [gitTask setArguments:@[@"git", @"rev-parse", @"HEAD"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [gitTask setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [gitTask launch];
    
    NSData *data = [file readDataToEndOfFile];
    self.latestRevision = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
