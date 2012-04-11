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
    
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setFetchLimit:500];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myFetchedResultsController = nil;
}

@end
