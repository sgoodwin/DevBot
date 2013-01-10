//
//  GOGitCheckOperation.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import <Foundation/Foundation.h>

@interface GOGitCheckOperation : NSOperation
@property (nonatomic, copy) NSString *latestRevision;
@property (nonatomic, copy) NSString *gitPullResults;

- (id)initWithProjectPath:(NSString *)path;
@end