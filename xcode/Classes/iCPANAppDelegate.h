//
//  iCPANAppDelegate.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-01.
//  Copyright WunderSolutions.com 2010. All rights reserved.
//

#import "Module.h"

@class SearchModuleViewController;

@interface iCPANAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    UIWindow *window;
    UITabBarController *tabBarController;
    SearchModuleViewController *searchModuleController;
	Module *selectedModule;
		
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) IBOutlet SearchModuleViewController *searchModuleController;
@property (nonatomic, retain) Module *selectedModule;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UIWindow *window;


- (NSString *)applicationDocumentsDirectory;
- (NSString *)cpanpod;
- (NSDictionary *)getBookmarks;
- (NSArray *)getRecentlyViewed;
- (BOOL)isBookmarked:(NSString *)moduleName;

@end
