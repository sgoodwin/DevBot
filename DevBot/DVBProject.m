#import "DVBProject.h"
#import "DVBConstants.h"
#import "DVBGitCheckOperation.h"
#import "DVBXcodeBuildOperation.h"
#import "DVBiOSPackagingOperation.h"
#import "DVBTestflightUploadOperation.h"


@interface DVBProject ()

// Private interface goes here.

@end


@implementation DVBProject

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

// TODO: decide on a good way to communicate git/build/package errors to the user when this is running on a headless machine.

- (void)updateInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext
{
    DVBProjectID *projectID = [self objectID];
    
    DVBGitCheckOperation *operation = [[DVBGitCheckOperation alloc] initWithProjectPath:self.folderPath];
    __weak DVBGitCheckOperation *weakOperation = operation;
    [weakOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        [childContext performBlock:^{
            DVBProject *resultProject = (DVBProject*)[childContext objectWithID:projectID];
            NSParameterAssert(resultProject);
            
            NSString *revision = weakOperation.latestRevision;
            if([revision isEqualToString:resultProject.revision]){
                [resultProject setStateValue:DVBProjectStateIdle];
            }else{
                [resultProject setRevision:weakOperation.latestRevision];
                
                // The revision is different than the one we had stored, so it's build time.
                [resultProject setStateValue:DVBProjectStateBuilding];
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
    DVBProjectID *projectID = [self objectID];
    
    DVBXcodeBuildOperation *buildOperation = [[DVBXcodeBuildOperation alloc] initWithPath:self.folderPath projectTitle:self.title];
    __weak DVBXcodeBuildOperation *weakOperation = buildOperation;
    [weakOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        NSError *buildError = weakOperation.error;
        NSString *appPath = weakOperation.appFilePath;
        
        [childContext performBlock:^{
            DVBProject *project = (DVBProject*)[childContext objectWithID:projectID];
            
            if(buildError){
                [project setStateValue:DVBProjectStateFailed];
            }else{
                project.appPath = appPath;
                
                
                [project setStateValue:DVBProjectStatePackaging];
                // TODO: This assumes we're building an iOS project. A different operation should be queued up for OS X projects.
                // It would sign with developer ID and such.
                [project packageInQueue:queue withContext:mainContext];
            }
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }
        }];
    }];
    
    [queue addOperation:buildOperation];
}

- (void)packageInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext
{
    DVBProjectID *projectID = [self objectID];
    
    DVBiOSPackagingOperation *packageOperation = [[DVBiOSPackagingOperation alloc] initWithAppPath:self.appPath title:self.title];
    __weak DVBiOSPackagingOperation *weakOperation = packageOperation;
    [packageOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        NSError *packageError = weakOperation.error;
        NSString *ipaPath = weakOperation.ipaPath;
        
        [childContext performBlock:^{
            DVBProject *project = (DVBProject*)[childContext objectWithID:projectID];
            project.ipaPath = ipaPath;
            if(packageError){
                [project setStateValue:DVBProjectStateFailed];
            }else{
                [project setStateValue:DVBPRojectStateUploading];
                [project uploadInQueue:queue withContext:mainContext];
            }
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }

        }];

    }];
    
    [queue addOperation:packageOperation];
}

- (void)uploadInQueue:(NSOperationQueue *)queue withContext:(NSManagedObjectContext *)mainContext
{
    DVBProjectID *projectID = [self objectID];
    
    DVBTestflightUploadOperation *uploadOperation = [[DVBTestflightUploadOperation alloc] initWithIPAPath:self.ipaPath];
    __weak DVBTestflightUploadOperation *weakOperation = uploadOperation;
    [uploadOperation setCompletionBlock:^{
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [childContext setParentContext:mainContext];
        
        NSError *uploadError = weakOperation.error;
        
        [childContext performBlock:^{
            DVBProject *project = (DVBProject*)[childContext objectWithID:projectID];
            
            if(uploadError){
                [project setStateValue:DVBProjectStateFailed];
            }else{
                [project setStateValue:DVBProjectStateIdle];
            }
            
            NSError *savingError = nil;
            if(![childContext save:&savingError]){
                NSLog(@"Failed to save child! %@", savingError);
            }
        }];
    }];
    
    [queue addOperation:uploadOperation];
}

@end
