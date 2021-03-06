//
//  SearchViewController.m
//  iCPAN
//
//  Created by Alders Olaf on 12-03-23.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import "SearchViewController.h"
#import "iCPANAppDelegate.h"

@implementation SearchViewController
@synthesize modules;
@synthesize myFetchedResultsController;
@synthesize searchBar; 
@synthesize searchString;
@synthesize myTableView;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    NSLog(@"===================== search %@", self.searchString);
    if (self.myFetchedResultsController != nil) {
        return myFetchedResultsController;
    }
    
    iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *MOC = del.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Module" inManagedObjectContext:MOC];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
                              initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSArray *keyPaths = [NSArray arrayWithObjects:@"distribution", @"distribution.author", nil];
    [fetchRequest setRelationshipKeyPathsForPrefetching:keyPaths];
    
    // the fetchLimit should be configurable
    [fetchRequest setFetchLimit:100];
    [fetchRequest setFetchBatchSize:20];
    
    myFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:MOC sectionNameKeyPath:nil 
                                                   cacheName:nil];
    return myFetchedResultsController;    
}


#pragma mark - Table view delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchTerm
{
    
    self.searchString = searchTerm;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"as_you_type"]) {
        return NO;
    }
    
    //at this point we could call an async method which would look up results and then reload the table
    NSLog(@"search string: %@", searchTerm);
    
    //"as you type" searching on very short strings is likely pointless
    if ([searchString length] > 2) {
        [self performSearch];
        return YES;
    }
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    NSLog(@"search bar clicked in shared class");
    [self performSearch];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)performSearch {
    
    NSString *searchText = self.searchString;
    searchText = [searchText stringByReplacingOccurrencesOfString:@"/" withString:@"::"];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //    if ([searchText isEqualToString:self.prevSearchText]) {
    //        return;
    //    }
    
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
    // Does the user want an exact match?
	if ( [searchWords count] == 1 && !([searchText rangeOfString:@".pm" options:NSBackwardsSearch].location == NSNotFound) ) {
		searchText = [searchText stringByReplacingOccurrencesOfString:@".pm" withString:@""];
		predicate = [NSPredicate predicateWithFormat:@"%K ==[cd] %@", attributeName, searchText];
	}
    else if([predicateArgs count] > 0) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArgs];
        if([predicateArgs count] ==1) {
            predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", attributeName, searchText];
            NSLog(@"-------------------------------------> starts with search");
        }
        else {
            // this search will bypass the db index and be very slow
        }
        
    // default to a list of recently viewed docs. i don't think we ever reach this code anymore
    } else {
        iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
        NSArray *recentlyViewed = del.getRecentlyViewed;
        predicate = [NSPredicate predicateWithFormat:@"%K IN[cd] %@", attributeName, recentlyViewed];
    }
    
    NSLog(@"predicate is now: %@", predicate);
    
    [self fetchedResultsController];
    
    [myFetchedResultsController.fetchRequest setPredicate:predicate];
    myFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    [myFetchedResultsController performFetch:&error];
    if (error) {
        // report error
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.myFetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    static NSString *module_cell = @"cellID";
    
    ModuleTableViewCell *cell = (ModuleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:module_cell];
    if (cell == nil) {
        cell = [[ModuleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:module_cell];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(ModuleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
	Module *module = (Module *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.module = module;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myFetchedResultsController = nil;
}

@end
