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
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Module *module = [self.myFetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"selected module %@", module);
    
    DetailViewController_iPhone *detailView = [[DetailViewController_iPhone alloc] init];
    
    detailView.detailItem = module;
    detailView.hidesBottomBarWhenPushed = YES;
	
    [[self navigationController] pushViewController:detailView animated:YES];
    [detailView configureView];
    
}

@end
