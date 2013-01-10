#import "GOProject.h"


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

@end
