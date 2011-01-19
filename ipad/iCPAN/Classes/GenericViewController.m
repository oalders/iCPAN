    //
//  GenericViewController.m
//  iCPAN
//
//  Created by Olaf Alders on 10-09-04.
//  Copyright 2010 wundersolutions.com. All rights reserved.
//

#import "GenericViewController.h"
#import "DetailViewController.h"
#import "iCPANAppDelegate.h"

@interface GenericViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation GenericViewController

@synthesize detailViewController, fetchedResultsController, managedObjectContext;



- (void)viewDidLoad {
	[super viewDidLoad];
	_data = [[NSMutableArray alloc] init];
	
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
		 Replace this implementation with code to handle the error appropriately.
		 abort() causes the application to generate a crash log and terminate.
		 You should not use this function in a shipping application, although
		 it may be useful during development. If it is not possible to recover
		 from the error, display an alert panel that instructs the user to quit
		 the application by pressing the Home button.
		 */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Overriden to allow any orientation.
	return YES;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"sections in table view: %d", [[fetchedResultsController sections] count]);
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	NSLog(@"rows in section: %d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Set the detail item in the detail view controller.
	NSLog(@"didselectrowatindexpath");
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    detailViewController.detailItem = selectedObject;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSLog(@"moc: %@", managedObjectContext);
	iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
	managedObjectContext = [ appDelegate managedObjectContext ];
	NSLog(@"moc: %@", managedObjectContext);
	
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"controllerWillChangeContent");
    //[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //[self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)mockSearch:(NSTimer*)timer
{
	[_data removeAllObjects];
	int count = 1 + random() % 20;
	for (int i = 0; i < count; i++) {
		[_data addObject:timer.userInfo];
	}
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(mockSearch:) userInfo:searchString repeats:NO];
	NSLog(@"searchdisplaycontroller: %@", searchString);
	[self filterContentForSearchText:searchString];
	return NO;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    
    searchText = [searchText stringByReplacingOccurrencesOfString:@"-" withString:@"::"];
    searchText = [searchText stringByReplacingOccurrencesOfString:@"/" withString:@"::"];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSLog(@"search text: %@", searchText);
	
}

- (void)dealloc {
	[_data release];
	
    [detailViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
	[super dealloc];
}


@end
