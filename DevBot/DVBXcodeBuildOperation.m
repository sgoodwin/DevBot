//
//  GOXcodeBuildOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "DVBXcodeBuildOperation.h"
#import "NSString+DVBFileTypes.h"

@implementation DVBXcodeBuildOperation

- (id)initWithPath:(NSString *)path projectTitle:(NSString *)title
{
    self = [super init];
    if(self){
        _folderPath = [path copy];
        _title = [title copy];
        _executing = NO;
        _finished = NO;
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
    NSString *resultsPath = [self buildDestinationPath];
    [buildTask setArguments:@[@"-configuration", @"Release", @"DEPLOYMENT_LOCATION=YES", [NSString stringWithFormat:@"DSTROOT=%@", resultsPath], [NSString stringWithFormat:@"DWARF_DSYM_FOLDER_PATH=%@", resultsPath]]];
    
    [buildTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSPipe *standardOuputPipe = [NSPipe pipe];
    [buildTask setStandardOutput:standardOuputPipe];
    
    NSFileHandle *standardOutputHandle = [standardOuputPipe fileHandleForReading];
        
    [buildTask launch];
    [buildTask waitUntilExit];
        
    NSData *standardOutputData = [standardOutputHandle readDataToEndOfFile];
    self.rawText = [[NSString alloc] initWithData:standardOutputData encoding:NSUTF8StringEncoding];
    
    if([buildTask terminationStatus] == DVBTaskSucessCode){
        [self findDsymAndAppFileInPath:resultsPath];
    }else{
        self.error = [self errorFromRawText];
    }
}

#pragma mark - Helpers

- (NSString *)buildDestinationPath
{
    // TODO: In the future this might be a user-supplied base directory.
    NSString *basePath = [@"~/Desktop/DevBotBuilds/" stringByExpandingTildeInPath];
    return [[basePath stringByAppendingPathComponent:self.title] stringByAppendingPathComponent:[[NSDate date] description]];
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

- (void)findDsymAndAppFileInPath:(NSString *)path
{
    // Hunting these down because the files are in different places depending on if you're building an OS X app or an iOS app.
    NSArray *keys = @[NSURLNameKey, NSURLPathKey];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        NSLog(@"Error looking for files at url %@: %@", url, error);
        return YES;
    }];
    
    for(NSURL *fileURL in enumerator){
        NSString *path = [fileURL path];
        if([path isPathToAppFile]){
            self.appFilePath = path;
        }
        if([path isPathToDSYMFile]){
            self.dSYMFilePath = path;
        }
    }
}

@end
