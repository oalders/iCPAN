//
//  SearchModuleViewController.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-01.
//  Copyright WunderSolutions.com 2010. All rights reserved.
//

@interface SearchModuleViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext     *managedObjectContext;
    
    NSString		*savedSearchTerm;
    NSString        *prevSearchText;
    BOOL			searchWasActive;

    UIView *recentlyViewedOverlay;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSString *savedSearchTerm;
@property (nonatomic, retain) NSString *prevSearchText;
@property (nonatomic) BOOL searchWasActive;

@property(retain) UIView *recentlyViewedOverlay;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@end
