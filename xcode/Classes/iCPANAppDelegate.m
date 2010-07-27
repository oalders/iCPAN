//
//  iCPANAppDelegate.m
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-01.
//  Copyright WunderSolutions.com 2010. All rights reserved.
//

#import "iCPANAppDelegate.h"
#import "SearchModuleViewController.h"

@implementation iCPANAppDelegate

@synthesize window;
@synthesize tabBarController, searchModuleController;
@synthesize selectedModule;

// We'll need to implement a check here to make sure all bookmarks still exist
// in the db.  Should only run when the app initializes
- (NSDictionary *)getBookmarks {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if([prefs dictionaryForKey:@"bookmarks"] == nil) {
		NSDictionary *bookmarks = [[[NSDictionary alloc] init] autorelease];
        [prefs setObject:bookmarks forKey:@"bookmarks"];
		[prefs synchronize];        
		return bookmarks;
	} else {
		return [prefs dictionaryForKey:@"bookmarks"];
	}
	
}


- (BOOL)isBookmarked:(NSString *)moduleName {

	NSDictionary *bookmarks = [self getBookmarks];
	
	for (id key in bookmarks) {
		if( [key isEqualToString:moduleName]) {
			return 1;
		}
	}
	
	return 0;
}


- (NSArray *)getRecentlyViewed {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if([prefs arrayForKey:@"recentlyViewed"] == nil) {
		NSArray *recentlyViewed = [[[NSArray alloc] init] autorelease];
        [prefs setObject:recentlyViewed forKey:@"recentlyViewed"];
		[prefs synchronize];        
		return recentlyViewed;
	} else {
		return [prefs arrayForKey:@"recentlyViewed"];
	}
}


// When the application launches, we'll clear out the cpanpod folder by 
// removing it completely.  We'll then recreate it and copy over the files
// we care about.  This means that we'll have a cache of files per session,
// but that we don't have to worry about these files when the app is upgraded

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
		
	NSFileManager *NSFm= [NSFileManager defaultManager]; 
	
	//start clean each time
	if ([NSFm removeItemAtPath: [self cpanpod] error: NULL]  == YES) {
        //NSLog (@"Remove successful");
	}
	else {
        NSLog (@"Remove failed");
	}

	[NSFm createDirectoryAtPath:[self cpanpod] attributes:nil];
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	bundlePath = [bundlePath stringByAppendingString:@"/"];
	NSError *error = nil;
	
	// Not sure of the best way to handle this, but it seems like we can't reliably predict where the cpanpod
    // folder will be, so we'll just copy over some resource files when needed
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:bundleRoot];
	NSArray *css = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH 's'"]];

	NSEnumerator *e = [css objectEnumerator];
	id file;
	while (file = [e nextObject]) {
		
		NSString *src = [bundlePath stringByAppendingString:file];
		NSString *dest = [self.cpanpod stringByAppendingString:file];

		if ( [[NSFileManager defaultManager] isReadableFileAtPath:src] )
			[[NSFileManager defaultManager] copyItemAtPath:src toPath:dest error:&error];
	}

}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"appDelegate applicationWillTerminate error %@, %@", error, [error userInfo]);
			exit(2);
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }	
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    /**
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"iCPAN.sqlite"];

	// Set up the store.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"iCPAN" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	*/
	
	NSString *storePath = [[NSBundle mainBundle] pathForResource:@"iCPAN" ofType:@"sqlite"];
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]] autorelease];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"appDelegate persistentStore error error %@, %@", error, [error userInfo]);
		exit(3);
    }    
    
    return persistentStoreCoordinator;
}


+ (void)initialize{
	
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:@"TextToSave" forKey:@"keyToLookupString"];
	
	[prefs synchronize];

}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cpanpod {
	return [[self applicationDocumentsDirectory] stringByAppendingString:@"/cpanpod/"];
}

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [searchModuleController release];
	[selectedModule release];
    [tabBarController release];
    [window release];
	
    [super dealloc];
}

@end

