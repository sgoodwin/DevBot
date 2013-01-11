//
//  DVBPackagingOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//
// Thanks to Jay Graves for pointing this out to me (http://skabber.com/package-your-ios-application-with-xcrun)


#import "DVBPackagingOperation.h"

@implementation DVBPackagingOperation

- (id)initWithAppPath:(NSString *)path
{
    self = [super init];
    if(self){
        _appPath = [path copy];
    }
    return self;
}

- (void)start
{
    self.executing = YES;
    
    [self packageApp];
    
    self.executing = NO;
    self.finished = YES;
}

- (void)packageApp
{
    
}

@end
