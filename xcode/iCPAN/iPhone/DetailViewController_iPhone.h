//
//  DetailViewController_iPhone.h
//  iCPAN
//
//  Created by Alders Olaf on 12-01-20.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "ModuleBookmark.h"

@interface DetailViewController_iPhone : DetailViewController

- (void) addBookmark;
- (void) activateBookmarkButton;
- (void) activateTrashButton;
- (void) removeBookmark;

@end
