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

// TODO: parsed error text should have proper error codes associated with things

- (void)buildProject
{
    NSTask *buildTask = [NSTask newXCodeBuildTask];
    if(!buildTask){
        self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Xcodebuild is not installed or is damaged."}];
        return;
    }
    
    [buildTask setCurrentDirectoryPath:self.folderPath];
    [buildTask setArguments:@[@"-configuration", @"Release"]];
    
    [buildTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSPipe *standardOuputPipe = [NSPipe pipe];
    [buildTask setStandardOutput:standardOuputPipe];
    
    NSFileHandle *standardOutputHandle = [standardOuputPipe fileHandleForReading];
        
    [buildTask launch];
    [buildTask waitUntilExit];
        
    NSData *standardOutputData = [standardOutputHandle readDataToEndOfFile];
    self.rawText = [[NSString alloc] initWithData:standardOutputData encoding:NSUTF8StringEncoding];
    
    if([buildTask terminationStatus] != DVBTaskSucessCode){
        self.error = [self errorFromRawText];
    }
}

- (NSError *)errorFromRawText
{
    NSError *error = nil;
    NSRegularExpression *errorRegex = [NSRegularExpression regularExpressionWithPattern:@".*:.*:.* error:.*" options:0 error:&error];
    NSParameterAssert(errorRegex);
    
    NSMutableSet *errorLines = [[NSMutableSet alloc] init];
    
    [errorRegex enumerateMatchesInString:self.rawText options:0 range:NSMakeRange(0, [self.rawText length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = [result rangeAtIndex:0];
        [errorLines addObject:[self.rawText substringWithRange:range]];
    }];
    
    NSString *errorString = [[errorLines allObjects] componentsJoinedByString:@", "];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{ NSLocalizedDescriptionKey: errorString }];
}

@end
