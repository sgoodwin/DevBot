//
//  DVBProjectManager.h
//  DevBot
//
//  Created by Doug Russell on 1/10/13.
//

#import <Foundation/Foundation.h>

@interface DVBProjectManager : NSObject

+ (instancetype)sharedInstance;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong) NSOperationQueue *processingQueue;

// Add project to database and save
- (void)addProjectAtPath:(NSString *)path withTitle:(NSString *)title;
// Save mainQueueContext
- (BOOL)saveMainQueueContext:(NSError **)error;
// Kick off project processing
- (void)processAllProjects;

@end
