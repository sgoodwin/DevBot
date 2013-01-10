//
//  GOXcodeBuildOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "GOXcodeBuildOperation.h"

@implementation GOXcodeBuildOperation

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if(self){
        self.folderPath = path;
        self.executing = NO;
        self.finished = NO;
    }
    return self;
}

- (void)start
{
    self.executing = YES;
    
    [self buildProject];
    NSLog(@"Raw: %@", self.rawText);
    
    self.executing = NO;
    self.finished = YES;
}

- (void)buildProject
{
    NSTask *gitTask = [NSTask newXCodeBuildTask];
    [gitTask setCurrentDirectoryPath:self.folderPath];
    [gitTask setArguments:@[@"-configuration", @"Release"]];
        
    NSPipe *pipe = [NSPipe pipe];
    [gitTask setStandardOutput:pipe];
        
    NSFileHandle *file = [pipe fileHandleForReading];
        
    [gitTask launch];
    [gitTask waitUntilExit];
        
    NSData *data = [file readDataToEndOfFile];
    self.rawText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
