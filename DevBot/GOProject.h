#import "_GOProject.h"

typedef NS_ENUM(NSUInteger, GOProjectState){
    GOProjectStateIdle,
    GOProjectStateWaiting,
    GOProjectStateBuilding
};

@interface GOProject : _GOProject {}
+ (NSArray *)allProjectsInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllProjectsInContext:(NSManagedObjectContext *)context;

- (void)updateInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext;
@end
