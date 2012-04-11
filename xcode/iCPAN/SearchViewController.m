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
@synthesize tableView;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.    
    [self searchModules];
    
    NSLog(@"numberOfRowsInSection: %u", [modules count] );
    return [modules count];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    NSLog(@"===================== search %@", self.searchString);
    if (self.myFetchedResultsController != nil) {
        NSLog(@"******************************************** fetchedResultsController already exists");
        return myFetchedResultsController;
    }
    
    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx controller init");
    
    
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

-(void) searchModules {
    NSLog(@"======================================= about to search modules");
    iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = del.managedObjectContext;
    
    if (searchString == nil ) {
        return;
    }
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[cd] %@", @"name", searchString];
    NSPredicate *beginsWith = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[cd] %@", @"name", searchString];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:beginsWith];
    [request setFetchBatchSize:10];
    [request setFetchLimit:100];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Module" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *searchResults = [context executeFetchRequest:request error:&error];
    self.modules = searchResults;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    // Configure the cell...
    NSLog(@"cell row: %i", indexPath.row );
    NSLog(@"results: %i", [modules count]);
    Module *module = [modules objectAtIndex:indexPath.row];
    NSLog(@"created cell %@", modules );
    NSLog(@"created cell %@", module.name );
    cell.textLabel.text = module.name;
    
    return cell;
}


#pragma mark - Table view delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"==========================search bar search button clicked");
    [self searchModules];
    [tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchTerm
{
    
    self.searchString = searchTerm;
    return YES;
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"as_you_type"]) {
        return NO;
    }
    
    return NO;
    
    //at this point we could call an async method which would look up results and then reload the table
    NSLog(@"search string: %@", searchTerm);
    
    //"as you type" searching on very short strings is likely pointless
    if ([searchString length] > 2) {
        [tableView reloadData];
        return YES;
    }
    return NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myFetchedResultsController = nil;
}

@end
