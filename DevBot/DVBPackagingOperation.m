//
//  DVBPackagingOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//
// Thanks to Jay Graves for pointing this out to me (http://skabber.com/package-your-ios-application-with-xcrun)


#import "DVBPackagingOperation.h"

@implementation DVBPackagingOperation

- (id)initWithAppPath:(NSString *)path title:(NSString *)title
{
    self = [super init];
    if(self){
        _appPath = [path copy];
        _title = [title copy];
        
        NSString *ipaName = [NSString stringWithFormat:@"%@.ipa", title];
        
        _ipaPath = [[@"~/Desktop/" stringByExpandingTildeInPath] stringByAppendingPathComponent:ipaName];
    }
    return self;
}

- (void)start
{
    self.executing = YES;
    
    if(![self packageApp]){
        NSLog(@"Failed to package app! %@ \n%@\n", self.error, self.rawText);
    }
    
    self.executing = NO;
    self.finished = YES;
}

- (BOOL)packageApp
{
    NSTask *packageTask = [NSTask newXCRunTask];
    [packageTask setArguments:@[@"-sdk", @"iphoneos", @"PackageApplication", @"-v", self.appPath, @"-o", [self ipaPath]]];
    
    NSPipe *pipe = [NSPipe pipe];
    [packageTask setStandardOutput:pipe];
    //[packageTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [packageTask launch];
    
    NSData *data = [file readDataToEndOfFile];
    self.rawText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [packageTask waitUntilExit];
    
    BOOL worked = [packageTask terminationStatus] == DVBTaskSucessCode;
    return worked;
}

#pragma mark - Helpers

- (NSString *)buildDestinationPath
{
    // TODO: In the future this might be a user-supplied base directory.
    NSString *basePath = [@"~/Desktop/DevBotBuilds/" stringByExpandingTildeInPath];
    return [[basePath stringByAppendingPathComponent:self.title] stringByAppendingPathComponent:[[NSDate date] description]];
}

@end
