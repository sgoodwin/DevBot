//
//  DVBPackagingOperation.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//

#import <Foundation/Foundation.h>

@interface DVBPackagingOperation : NSOperation
@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) NSString *appPath;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSString *ipaPath;

- (id)initWithAppPath:(NSString *)path;
@end
