//
//  SearchViewController.h
//  iCPAN
//
//  Created by Alders Olaf on 12-03-23.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleTableViewCell.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *myFetchedResultsController;
    UISearchBar *searchBar;
    NSString *searchString;
}

@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) NSFetchedResultsController *myFetchedResultsController;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) IBOutlet UITableView *myTableView;

-(void)configureCell:(ModuleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void) performSearch;
-(NSFetchedResultsController *)fetchedResultsController;

@end
