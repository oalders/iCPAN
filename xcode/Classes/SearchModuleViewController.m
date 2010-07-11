//
//  SearchModuleViewController.m
//  iCPAN
//
//  Created by WunderSolutions.com on 10-03-01.
//  Copyright WunderSolutions.com 2010. All rights reserved.
//

#import "SearchModuleViewController.h"
#import "MasterViewController.h"
#import "Module.h"
#import "Author.h"
#import "ModuleTableViewCell.h"
#import "iCPANAppDelegate.h"


@implementation SearchModuleViewController

@synthesize savedSearchTerm, savedScopeButtonIndex, searchWasActive, prevSearchText;
@synthesize fetchedResultsController, managedObjectContext;


- (void)viewDidLoad {
	
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }

    // get the contex object -- for some reason it the order of loading of our files is causing this
    // implementation to load before the AppDelegate, so pushing the context into here doesn't work.
    if (managedObjectContext == nil) 
    { 
        self.managedObjectContext = [(iCPANAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    }

    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		 
		NSLog(@"fetchedResultsController error %@, %@", error, [error userInfo]);
		exit(1);
	}    
    [[self fetchedResultsController] performFetch:&error];
	[self.tableView reloadData];
    self.tableView.scrollEnabled = YES;

    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	//NSLog(@"memory warning received");
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    self.fetchedResultsController = nil;
    
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSArray *recentlyViewed = appDelegate.getRecentlyViewed;
        
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];

        [fetchRequest setFetchLimit:100];
		[fetchRequest setFetchBatchSize:20];
        NSPredicate *predicate = nil;
        NSString *attributeName = @"name";
        if([recentlyViewed count]) {
            predicate = [NSPredicate predicateWithFormat:@"%K IN[cd] %@", attributeName, recentlyViewed];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"%K == ''", attributeName];
        }
        [fetchRequest setPredicate:predicate];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [sortDescriptors release];
        [sortDescriptor release];
        [fetchRequest release];
    }

	return fetchedResultsController;
}

# pragma mark -
# pragma mark UITableView data source and delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    static NSString *kCellID = @"cellID";

    ModuleTableViewCell *cell = (ModuleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[[ModuleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(ModuleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
	Module *module = (Module *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.module = module;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MasterViewController *detailsViewController = [[MasterViewController alloc] init];
    
    Module *module = nil;
    module = (Module *)[fetchedResultsController objectAtIndexPath:indexPath];

    detailsViewController.title = module.name;
    
	detailsViewController.hidesBottomBarWhenPushed = YES;
	
	iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.selectedModule = module;
	
    [[self navigationController] pushViewController:detailsViewController animated:YES];
    [detailsViewController release];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    searchText = [searchText stringByReplacingOccurrencesOfString:@"-" withString:@"::"];
    searchText = [searchText stringByReplacingOccurrencesOfString:@"/" withString:@"::"];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([searchText isEqualToString:self.prevSearchText]) {
        return;
    }
    
    NSArray *searchWords = [searchText componentsSeparatedByString:@" "];

    NSMutableArray *predicateArgs = [[NSMutableArray alloc] init];
    NSString *attributeName = @"name";
    
    for (NSString *word in searchWords) {
        if(![word isEqualToString:@""]) {
            NSPredicate *wordPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", attributeName, word];
            [predicateArgs addObject:wordPredicate];
        }
    }

    NSPredicate *predicate = nil;
	if ( [searchWords count] == 1 && !([searchText rangeOfString:@".pm" options:NSBackwardsSearch].location == NSNotFound) ) {
		searchText = [searchText stringByReplacingOccurrencesOfString:@".pm" withString:@""];
		predicate = [NSPredicate predicateWithFormat:@"%K ==[cd] %@", attributeName, searchText];
	}
    else if([predicateArgs count] > 0) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArgs];
        if([predicateArgs count] ==1) {
            NSPredicate *beginsPred = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", attributeName, searchText];
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:beginsPred, predicate, nil]];
        }
    } else {
        iCPANAppDelegate *appDelegate = (iCPANAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *recentlyViewed = appDelegate.getRecentlyViewed;
        predicate = [NSPredicate predicateWithFormat:@"%K IN[cd] %@", attributeName, recentlyViewed];
    }
    [fetchedResultsController.fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"filtered fetchedResultsController error %@, %@", error, [error userInfo]);
        exit(1);
    }

    self.prevSearchText = searchText;
    [self.tableView reloadData];

    [predicateArgs release];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)dealloc {
    
	[fetchedResultsController release];
	[managedObjectContext release];
	[prevSearchText release];
	[savedSearchTerm release];
    
    [super dealloc];
}



@end
