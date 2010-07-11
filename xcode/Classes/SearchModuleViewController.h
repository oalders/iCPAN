//
//  SearchModuleViewController.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-01.
//  Copyright WunderSolutions.com 2010. All rights reserved.
//

@interface SearchModuleViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext     *managedObjectContext;
    
    NSString		*savedSearchTerm;
    NSString        *prevSearchText;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *savedSearchTerm;
@property (nonatomic, retain) NSString *prevSearchText;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end
