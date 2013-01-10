#import "GOProject.h"
#import "GOConstants.h"
#import "GOGitCheckOperation.h"
#import "GOXcodeBuildOperation.h"

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
            
            NSString *revision = weakOperation.latestRevision;
            if([revision isEqualToString:resultProject.revision]){
                [resultProject setStateValue:GOProjectStateIdle];
            }else{
                [resultProject setRevision:weakOperation.latestRevision];
                
                // The revision is different than the one we had stored, so it's build time.
                [resultProject setStateValue:GOProjectStateBuilding];
                [resultProject buildInQueue:queue withContext:mainContext];
            }
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }
        }];
    }];
    [queue addOperation:operation];
}

- (void)buildInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext
{
    GOProjectID *projectID = [self objectID];
    
    GOXcodeBuildOperation *buildOperation = [[GOXcodeBuildOperation alloc] initWithPath:self.path];
    __weak GOXcodeBuildOperation *weakOperation = buildOperation;
    [weakOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        [childContext performBlock:^{
            GOProject *project = (GOProject*)[childContext objectWithID:projectID];
            [project setStateValue:GOProjectStateIdle];
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }
        }];
    }];
    
    [queue addOperation:buildOperation];
}

@end
