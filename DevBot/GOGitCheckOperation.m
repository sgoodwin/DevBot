//
//  GOGitCheckOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "GOGitCheckOperation.h"

@interface GOGitCheckOperation()
@property (nonatomic, strong) NSString *folderPath;
@end

@implementation GOGitCheckOperation

- (id)initWithProjectPath:(NSString *)path
{
    self = [super init];
    if(self){
        self.folderPath = [path copy];
    }
    return self;
}

- (void)start
{
    if([self pullFromBranch:@"master"]){
        [self retrieveLatestRevision];
    }else{
        NSLog(@"Failed to pull to latest!");
    }
    NSLog (@"Git Operation Results: %@", self.latestRevision);
}

#pragma mark - Helpers

- (BOOL)pullFromBranch:(NSString *)branch
{
    NSTask *gitTask = [[NSTask alloc] init];
    [gitTask setLaunchPath:@"/usr/bin/xcrun"];
    [gitTask setCurrentDirectoryPath:self.folderPath];
    [gitTask setArguments:@[@"git", @"pull", @"origin", branch]];
    
    NSPipe *pipe = [NSPipe pipe];
    [gitTask setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [gitTask launch];
    
    NSData *data = [file readDataToEndOfFile];
    self.gitPullResults = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [gitTask waitUntilExit];
    
    BOOL worked = [gitTask terminationStatus] == 0;
    return worked;
}

- (void)retrieveLatestRevision
{
    NSTask *gitTask = [[NSTask alloc] init];
    [gitTask setLaunchPath:@"/usr/bin/xcrun"];
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