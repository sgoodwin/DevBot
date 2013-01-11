#import "_DVBProject.h"

@interface DVBProject : _DVBProject {}

+ (NSArray *)allProjectsInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllProjectsInContext:(NSManagedObjectContext *)context;

- (void)updateInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext;

@end
