//
//  DVBPackagingOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//
// Thanks to Jay Graves for pointing this out to me (http://skabber.com/package-your-ios-application-with-xcrun)


#import "DVBiOSPackagingOperation.h"

@implementation DVBiOSPackagingOperation

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
    [packageTask setEnvironment:@{
     @"CODESIGN_ALLOCATE": @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate",
     @"PATH": @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"}];
    [packageTask setArguments:@[@"-sdk", @"iphoneos", @"PackageApplication", @"-v", self.appPath, @"-o", [self ipaPath], @"--sign", @"iPhone Distribution: Samuel Ryan Goodwin", @"--embed", @"/Users/sgoodwin/Library/MobileDevice/Provisioning Profiles/063D014E-A00D-461D-B524-3EA9EA248D1A.mobileprovision"]];
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    [packageTask setStandardOutput:outputPipe];
    [packageTask setStandardError:errorPipe];
    
    NSFileHandle *outputFile = [outputPipe fileHandleForReading];
    NSFileHandle *errorFile = [errorPipe fileHandleForReading];
    
    [packageTask launch];
    
    NSData *outputData = [outputFile readDataToEndOfFile];
    self.rawText = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    [packageTask waitUntilExit];
    
    BOOL worked = [packageTask terminationStatus] == DVBTaskSucessCode;
    if(!worked){
        NSData *errorData = [errorFile readDataToEndOfFile];
        self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding]}];
    }
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
