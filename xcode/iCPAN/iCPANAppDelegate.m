//
//  iCPANAppDelegate.m
//  iCPAN
//
//  Created by Olaf Alders on 11-03-31.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "iCPANAppDelegate.h"

@implementation iCPANAppDelegate

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"did finish launching main app delegate");
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iCPAN" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *storePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iCPAN.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];

    NSLog(@"store url %@", storePath);
    
    // uncomment if recreating the database
    //
    //storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iCPAN.sqlite"];
    NSLog(@"DB: %@", storeURL);
    
    NSDictionary *storeOptionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSReadOnlyPersistentStoreOption];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptionsDict error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSArray *)getRecentlyViewed {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if([prefs arrayForKey:@"recentlyViewed"] == nil) {
		NSArray *recentlyViewed = [[NSArray alloc] init];
        [prefs setObject:recentlyViewed forKey:@"recentlyViewed"];
		[prefs synchronize];        
		return recentlyViewed;
	} else {
		return [prefs arrayForKey:@"recentlyViewed"];
	}
}

- (NSURL *)podURL {
    return [NSURL fileURLWithPath:[self podDir]];
}

- (NSString *) podDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingString:@"/cpanpod/"];
}

-(void) createPodFolder {
    
	NSFileManager *FM= [NSFileManager defaultManager]; 
    NSError *createError;
	NSError *error = nil;
	
	//start clean each time
    if ([FM removeItemAtPath:self.podDir error:&error] ) {
        //NSLog (@"Remove successful");
	}
	else {
        NSLog (@"Remove failed");
	}
        
	[FM createDirectoryAtPath:self.podDir withIntermediateDirectories:NO attributes:nil error:&createError];
    
    NSLog(@"error: %@", createError);
    
	NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
    
    NSLog(@"resource path: %@", resourcePath);
	
	NSArray *dirContents = [FM contentsOfDirectoryAtPath:resourcePath error:&createError];
    
    NSLog(@"dircontents %@", dirContents);
	NSArray *css = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH 's'"]];

	id file;
    for (file in css ) {
		
		NSString *src = [resourcePath stringByAppendingString:file];
		NSString *dest = [self.podDir stringByAppendingString:file];
        NSLog(@"src: %@", file);
        
		if ( [FM isReadableFileAtPath:src] )
			[FM copyItemAtPath:src toPath:dest error:&error];
	}

}

@end
