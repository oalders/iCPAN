//
//  SearchViewController_iPad.m
//  iCPAN
//
//  Created by Olaf Alders on 11-05-18.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "iCPANAppDelegate_iPad.h"
#import "SearchViewController_iPad.h"
#import "DetailViewController_iPad.h"

@implementation SearchViewController_iPad

@synthesize context;
@synthesize detailViewController;
@synthesize tableView;

- (void)performSearch {
    
    NSString *searchText = self.searchString;
    searchText = [searchText stringByReplacingOccurrencesOfString:@"-" withString:@"::"];
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
        iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
        NSArray *recentlyViewed = del.getRecentlyViewed;
        predicate = [NSPredicate predicateWithFormat:@"%K IN[cd] %@", attributeName, recentlyViewed];
    }
    
    NSLog(@"predicate is now: %@", predicate);
    
    [super fetchedResultsController];

    [myFetchedResultsController.fetchRequest setPredicate:predicate];
    myFetchedResultsController.delegate = self;
    
    NSError * error = nil;
    [myFetchedResultsController performFetch:&error];
    if (error) {
        // report error
    }
    
    
    
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.myFetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
        
    // Configure the cell.
    Module *module = [self.myFetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"fetched result: %@", [module name]);

    cell.textLabel.text = [module name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the detail item in the detail view controller.
    Module *module = [self.myFetchedResultsController objectAtIndexPath:indexPath];
    detailViewController.detailItem = module;
}


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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search bar search button clicked");    
    [[[self searchDisplayController] searchResultsTableView] reloadData];
}


- (void)dealloc
{
    self.myFetchedResultsController.delegate = nil;
    
}

@end
