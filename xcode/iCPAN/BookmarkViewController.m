//
//  BookmarkViewController.m
//  iCPAN
//
//  Created by Olaf Alders on 11-10-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "BookmarkViewController.h"
#import "DetailViewController.h"
#import "iCPANAppDelegate.h"

@implementation BookmarkViewController

@synthesize myFetchedResultsController;
@synthesize managedObjectContext;


- (void)viewWillAppear:(BOOL)animated {
	
	NSDictionary *bookmarks = [ModuleBookmark getBookmarks];
	
	if( bookmarks.count == 0 ) {
		[self.tableView reloadData];
		self.navigationItem.rightBarButtonItem = nil;
		return;
	}
    
	self.tableView.scrollEnabled = YES;
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
	// get the contex object -- for some reason it the order of loading of our files is causing this
    // implementation to load before the AppDelegate, so pushing the context into here doesn't work.
    if (managedObjectContext == nil) {
        iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
        managedObjectContext = del.managedObjectContext;    
    }
    
    [self performSearch];


    NSLog(@"bookmarkview willappear");
    
	[self.tableView reloadData];
    
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

    if (self.myFetchedResultsController != nil) {
        return self.myFetchedResultsController;
    }
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];        
    [fetchRequest setFetchBatchSize:20];

    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.myFetchedResultsController = aFetchedResultsController;
	return self.myFetchedResultsController;
    
}

- (void) performSearch {
    NSDictionary *bookmarks = [ModuleBookmark getBookmarks];
    NSLog(@"performSearch begins");
    if([bookmarks count]) {
        NSString *attributeName = @"name";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN[cd] %@", attributeName, [bookmarks allKeys]];
        [[self fetchedResultsController].fetchRequest setPredicate:predicate];
        NSError *error = nil;
        [self fetchedResultsController];
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            
            //NSLog(@"fetchedResultsController error %@, %@", error, [error userInfo]);
            exit(1);
        }
    }
}


# pragma mark -
# pragma mark UITableView data source and delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    static NSString *kCellID = @"cellID";
    
    ModuleTableViewCell *cell = (ModuleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[ModuleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //UITableView *tableView = self.tableView;
		Module *module = (Module *)[[self fetchedResultsController] objectAtIndexPath:indexPath];

        [tableView beginUpdates];
        

        [ModuleBookmark removeBookmark:module.name];
        
        //self.myFetchedResultsController = nil;
        //[self fetchedResultsController];  
        NSError *error = nil;

        if (![[self fetchedResultsController] performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            
            //NSLog(@"fetchedResultsController error %@, %@", error, [error userInfo]);
            exit(1);
        }
		// this always throws an error
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationFade]; 
        [tableView endUpdates];
	}
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    self.myFetchedResultsController = nil;
}

@end
