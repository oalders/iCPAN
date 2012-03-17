//
//  SearchViewController_iPad.h
//  iCPAN
//
//  Created by Olaf Alders on 11-05-18.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController_iPad.h"

@class SearchViewController_iPad;

@interface SearchViewController_iPad : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *context;
    UITableView *tableView;
}

@property (nonatomic, strong) IBOutlet DetailViewController_iPad *detailViewController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *searchString;

@end
