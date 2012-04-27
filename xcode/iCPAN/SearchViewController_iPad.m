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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set the detail item in the detail view controller.
    Module *module = [self.myFetchedResultsController objectAtIndexPath:indexPath];
    detailViewController.detailItem = module;
}

@end
