//
//  GOAppDelegate.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GOAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
