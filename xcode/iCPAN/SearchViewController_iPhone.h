//
//  ModuleController.h
//  iCPAN
//
//  Created by Olaf Alders on 11-10-16.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    UITableView *tv;
    UISearchBar *searchBar;
    NSString *searchString;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

-(void) searchModules;

@end