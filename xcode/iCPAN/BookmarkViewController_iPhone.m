//
//  BookmarkViewController_iPhone.m
//  iCPAN
//
//  Created by Alders Olaf on 12-04-02.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import "BookmarkViewController_iPhone.h"
#import "DetailViewController_iPhone.h"

@implementation BookmarkViewController_iPhone

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    NSLog(@"didselectrow %@",self.fetchedResultsController);
    Module *module = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"selected module %@", module);
    
    DetailViewController_iPhone *detailView = [[DetailViewController_iPhone alloc] init];
    
    detailView.detailItem = module;
    detailView.hidesBottomBarWhenPushed = YES;
	
    [[self navigationController] pushViewController:detailView animated:YES];
    [detailView configureView];
    
}

@end
