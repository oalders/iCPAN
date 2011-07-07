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

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) saveContext;
- (void) createPodFolder;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)docURL;
- (NSURL *)podURL;
- (NSString *) docDir;
- (NSString *)podDir;
- (NSDictionary *)getBookmarks;
- (NSArray *)getRecentlyViewed;
- (BOOL)isBookmarked:(NSString *)moduleName;

@end
