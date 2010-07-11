//
//  BookmarksViewController.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-15.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

@interface BookmarksViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext     *managedObjectContext;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
