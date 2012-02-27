//
//  ModuleController.h
//  iCPAN
//
//  Created by Olaf Alders on 11-10-16.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tv;
    UISearchBar *searchBar;
    NSString *searchString;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *modules;
@property (nonatomic, retain) NSString *searchString;

-(void) searchModules;

@end