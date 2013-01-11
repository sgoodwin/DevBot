//
//  GOXcodeBuildOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "DVBXcodeBuildOperation.h"

@implementation DVBXcodeBuildOperation

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

// TODO: For whoever writes the log parser / error handling for xcodebuild
// "Error: Can't run /Applications/Xcode.app/usr/bin/xcodebuild (no such file)."
// Is caused by xcode-select being pointed at a bad directory, in this case
// /Applications/Xcode.app, instead of /Applications/Xcode.app/Contents/Developer
// We can likely detect this specific issue and prompt the user to fix it
// using sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer 
// (or we could write a privileged task operation to do it for them)

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
