//
//  DVBTestflightUploadOperation.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/13/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import "DVBTestflightUploadOperation.h"

@implementation DVBTestflightUploadOperation

- (id)initWithIPAPath:(NSString *)path
{
    self = [super init];
    if(self){
        _ipaPath = [path copy];
        
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (void)start
{
    NSParameterAssert(self.ipaPath);
    self.executing = YES;
    
    [self uploadToTestflight];
}

- (void)uploadToTestflight
{
    NSData *data = [NSData dataWithContentsOfFile:self.ipaPath];
    NSParameterAssert(data);
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://testflightapp.com/api/builds.plist"]];
    [request setHTTPMethod:@"POST"];
    
    NSString *stringBoundary = @"weifhewpfiohefpohef";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
    
    NSDictionary *values = @{@"api_token": @"e6484c16818ef57f0ed9b1496a737600_NDgwNTg", @"team_token": @"e5761d6a6f1233beec386be3d938f1c3_OTgyNDIwMTEtMTItMjIgMTc6Mjk6MzguODA4ODQ2", @"notes": @"A new build brought to you by DevBot!"};
    
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:encoding]];
        [postBody appendData:[obj dataUsingEncoding:encoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:encoding]];
    }];
    
    //add data field and file data
	[postBody appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"app.ipa\"\r\n" dataUsingEncoding:encoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:encoding]];
	[postBody appendData:data];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:encoding]];
    
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:encoding];
        NSLog(@"Upload response: %@", responseString);
        
        self.executing = NO;
        self.finished = YES;
    }];
}

@end
