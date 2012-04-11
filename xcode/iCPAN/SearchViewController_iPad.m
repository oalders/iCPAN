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

@synthesize detailViewController;

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


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search bar search button clicked");    
    [[[self searchDisplayController] searchResultsTableView] reloadData];
}


- (void)dealloc
{
    self.myFetchedResultsController.delegate = nil;
    
}

@end
