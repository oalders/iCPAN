//
//  SearchViewController.h
//  iCPAN
//
//  Created by Alders Olaf on 12-03-23.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    UISearchBar *searchBar;
    NSString *searchString;
    UITableView *tv;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(void) searchModules;

@end
