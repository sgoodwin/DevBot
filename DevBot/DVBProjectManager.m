//
//  DVBProjectManager.m
//  DevBot
//
//  Created by Doug Russell on 1/10/13.
//

#import "DVBProjectManager.h"
#import "DVBProject.h"
#import "DVBConstants.h"

@interface DVBProjectManager ()
@property (nonatomic, strong) NSTimer *processingTimer;
@end

@implementation DVBProjectManager
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize mainQueueContext = _managedObjectContext;

#pragma mark - Setup/Cleanup

+ (instancetype)sharedInstance
{
	static id instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [self new];
	});
	return instance;
}

- (instancetype)init
{
	self = [super init];
	if (self){
		_processingQueue = [[NSOperationQueue alloc] init];
		_processingQueue.name = @"com.roundwall.DevBot";
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
		
		// Every 5 minutes do the damn thing.
		_processingTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(processAllProjects) userInfo:nil repeats:YES];
	}
	return self;
}

#pragma mark - Accessors

- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.roundwallsoftware.DevBot"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DevBot" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"DevBot.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainQueueContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Notifications

- (void)didChangeContext:(NSNotification *)notification
{
    
}

#pragma mark - Public API

- (void)processAllProjects
{
    NSLog(@"Processing projects...");
    NSManagedObjectContext *mainQueueContext = [self mainQueueContext];
	NSOperationQueue *processingQueue = [self processingQueue];
    NSArray *projects = [DVBProject allProjectsInContext:mainQueueContext];
    
    [projects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DVBProject *project = obj;
        [project setStateValue:DVBProjectStateWaiting];
        
        NSError *savingError = nil;
        if(![mainQueueContext save:&savingError]){
            NSLog(@"Failed to save changing project to waiting: %@", savingError);
        }
        
        [project updateInQueue:processingQueue withContext:mainQueueContext];
    }];
    
}

- (BOOL)saveMainQueueContext:(NSError **)error
{
	NSManagedObjectContext *mainQueueContext = [self mainQueueContext];
	if (![mainQueueContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
	return [mainQueueContext save:error];
}

- (void)addProjectAtPath:(NSString *)path withTitle:(NSString *)title
{
	NSParameterAssert(path);
	NSParameterAssert(title);
	
	// TODO: sanity checks to make sure this result is actually an xcode project
	
	NSManagedObjectContext *mainQueueContext = [self mainQueueContext];
	
	// TODO: get rid of this and implement deduplication
	[DVBProject deleteAllProjectsInContext:mainQueueContext];
	
	DVBProject *project = [DVBProject insertInManagedObjectContext:mainQueueContext];
	project.title = title;
	project.path = path;
	project.stateValue = DVBProjectStateIdle;
	[self saveMainQueueContext:nil];
}

@end
