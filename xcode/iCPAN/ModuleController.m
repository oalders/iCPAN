//
//  ModuleController.m
//  iCPAN
//
//  Created by Olaf Alders on 11-10-16.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "ModuleController.h"
#import "iCPANAppDelegate_iPhone.h"
#import "ModuleViewController.h"

@implementation ModuleController

@synthesize fetchedResultsController;
@synthesize modules; 
@synthesize searchBar; 
@synthesize searchString;
@synthesize tableView;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Module *module = [self.modules objectAtIndex:indexPath.row];

    NSLog(@"selected module %@", module);
        
    ModuleViewController *webView = [[ModuleViewController alloc] initWithNibName:@"ModuleViewController" bundle:nil];

    [self.navigationController pushViewController:webView animated:YES];
    
     
}

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
    [request setFetchBatchSize:5];
    [request setFetchLimit:10];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Module" inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *searchResults = [context executeFetchRequest:request error:&error];
    self.modules = searchResults;
}

@end
