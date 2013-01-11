//
//  DVBPackagingOperation.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/11/13.
//

#import <Foundation/Foundation.h>

@interface DVBiOSPackagingOperation : NSOperation
@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *appPath;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSString *ipaPath;
@property (nonatomic, copy) NSString *rawText;

- (id)initWithAppPath:(NSString *)path title:(NSString *)title;
@end
