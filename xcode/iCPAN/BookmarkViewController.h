//
//  BookmarkViewController.h
//  iCPAN
//
//  Created by Olaf Alders on 11-10-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleBookmark.h"
#import "ModuleTableViewCell.h"

@interface BookmarkViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext     *managedObjectContext;

}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(ModuleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
