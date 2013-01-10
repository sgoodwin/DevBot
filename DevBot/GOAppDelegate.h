//
//  GOAppDelegate.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import <Cocoa/Cocoa.h>

@interface GOAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong) NSOperationQueue *processingQueue;

- (IBAction)saveAction:(id)sender;

- (IBAction)addProject:(id)sender;
- (IBAction)runSomething:(id)sender;
@end
