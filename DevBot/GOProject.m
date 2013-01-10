#import "GOProject.h"
#import "GOGitCheckOperation.h"

@implementation GOProject

+ (NSArray *)allProjectsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self entityInManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *projects = [context executeFetchRequest:request error:&error];
    if(!projects){
        NSLog(@"Error fetching projects: %@", error);
        NSParameterAssert(projects);
    }
    return projects;
}

+ (void)deleteAllProjectsInContext:(NSManagedObjectContext *)context
{
    [[self allProjectsInContext:context] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
}

- (void)updateInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext
{
    GOProjectID *projectID = [self objectID];
    
    GOGitCheckOperation *operation = [[GOGitCheckOperation alloc] initWithProjectPath:[self path]];
    __weak GOGitCheckOperation *weakOperation = operation;
    [weakOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        [childContext performBlock:^{
            GOProject *resultProject = (GOProject*)[childContext objectWithID:projectID];
            NSParameterAssert(resultProject);
            [resultProject setRevision:weakOperation.latestRevision];
            NSLog(@"Result project has revision: %@", resultProject.revision);
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }
        }];
    }];
    [queue addOperation:operation];
}

@end
