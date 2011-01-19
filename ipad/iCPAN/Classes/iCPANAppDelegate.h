//
//  iCPANAppDelegate.h
//  iCPAN
//
//  Created by Olaf Alders on 10-09-01.
//  Copyright wundersolutions.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class DetailViewController;
@class GenericViewController;

@interface iCPANAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;

	UISplitViewController *splitViewController;
	GenericViewController *genericViewController;
	DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet GenericViewController *genericViewController;

@end
