//
//  SearchViewController_iPhone.m
//  iCPAN
//
//  Created by Olaf Alders on 11-10-16.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "SearchViewController_iPhone.h"
#import "iCPANAppDelegate_iPhone.h"
#import "DetailViewController_iPhone.h"

@implementation SearchViewController_iPhone


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"==========================search bar search button clicked");
    [self searchModules];
    [super.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Module *module = [self.modules objectAtIndex:indexPath.row];
    
    NSLog(@"selected module %@", module);
    
    DetailViewController_iPhone *detailView = [[DetailViewController_iPhone alloc] init];
    
    detailView.detailItem = module;
    detailView.title = module.name;
    detailView.hidesBottomBarWhenPushed = YES;
	
    [[self navigationController] pushViewController:detailView animated:YES];
    [detailView configureView];
    
}

@end
