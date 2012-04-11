//
//  SearchViewController_iPad.h
//  iCPAN
//
//  Created by Olaf Alders on 11-05-18.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController_iPad.h"
#import "SearchViewController.h"

@class SearchViewController_iPad;

@interface SearchViewController_iPad : SearchViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSManagedObjectContext *context;
    NSFetchedResultsController *myFetchedResultsController;
    UITableView *tableView;
}

@property (nonatomic, strong) IBOutlet DetailViewController_iPad *detailViewController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *myFetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;

@end
