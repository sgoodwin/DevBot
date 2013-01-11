//
//  DVBAppDelegate.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "DVBAppDelegate.h"

@interface DVBAppDelegate()
@property (strong, nonatomic) DVBProjectManager *projectManager;
@end

@implementation DVBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Spin up project manager
	self.projectManager = [DVBProjectManager sharedInstance];
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self.projectManager mainQueueContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error;
    if (![self.projectManager saveMainQueueContext:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
	NSManagedObjectContext *mainQueueContext = [self.projectManager mainQueueContext];
    if (!mainQueueContext) {
        return NSTerminateNow;
    }
    
    if (![mainQueueContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![mainQueueContext hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![mainQueueContext save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [NSApp presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

- (IBAction)addProject:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseDirectories:YES];
	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		NSString *title = [panel.URL lastPathComponent];
		NSString *path = [panel.URL path];
		[self.projectManager addProjectAtPath:path withTitle:title];
	}];
}

- (IBAction)runSomething:(id)sender
{
    [self.projectManager processAllProjects];
}

@end
