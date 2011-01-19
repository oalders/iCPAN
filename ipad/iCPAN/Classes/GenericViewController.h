//
//  GenericViewController.h
//  iCPAN
//
//  Created by Olaf Alders on 10-09-04.
//  Copyright 2010 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class DetailViewController;

@interface GenericViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UISearchBarDelegate> {
	NSMutableArray* _data;
	
	DetailViewController *detailViewController;
	
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}


@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
