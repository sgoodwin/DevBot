#import "_GOProject.h"

@interface GOProject : _GOProject {}
+ (NSArray *)allProjectsInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllProjectsInContext:(NSManagedObjectContext *)context;

- (void)updateInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext;
@end
