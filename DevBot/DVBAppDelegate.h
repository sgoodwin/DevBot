//
//  DVBAppDelegate.h
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import <Cocoa/Cocoa.h>

@interface DVBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)saveAction:(id)sender;

- (IBAction)addProject:(id)sender;
- (IBAction)runSomething:(id)sender;

@end
