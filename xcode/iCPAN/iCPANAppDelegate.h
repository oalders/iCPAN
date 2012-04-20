//
//  iCPANAppDelegate.h
//  iCPAN
//
//  Created by Olaf Alders on 11-03-31.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module.h"

@interface iCPANAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) IBOutlet UIWindow                      *window;

@property (nonatomic, strong, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)    applicationDocumentsDirectory;
- (void)       createPodFolder;
- (NSArray *)  getRecentlyViewed;
- (NSString *) podDir;
- (NSURL *)    podURL;
- (void)       saveContext;

@end
