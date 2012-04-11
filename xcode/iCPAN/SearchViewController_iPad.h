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

@interface SearchViewController_iPad : SearchViewController <UISearchDisplayDelegate> {
}

@property (nonatomic, strong) IBOutlet DetailViewController_iPad *detailViewController;

@end
