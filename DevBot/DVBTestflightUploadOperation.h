//
//  DVBTestflightUploadOperation.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/13/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVBTestflightUploadOperation : NSOperation
@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) NSString *ipaPath;
@property (nonatomic, strong) NSError *error;

- (id)initWithIPAPath:(NSString *)path;
@end
