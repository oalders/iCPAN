//
//  DetailViewController_iPhone.m
//  iCPAN
//
//  Created by Alders Olaf on 12-01-20.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import "DetailViewController_iPhone.h"

@implementation DetailViewController_iPhone

- (void)setDetailItem:(Module *)managedObject
{
	NSLog(@"setDetailItem in iPhone");
    [super setDetailItem:managedObject];
    super.bottomSpacerHeight = [NSNumber numberWithInt:1];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewwillappear iphone");

    if ([ModuleBookmark isBookmarked:[self.detailItem valueForKey:@"name"]] ) {
        [self activateTrashButton];
    }
    else{
        [self activateBookmarkButton];
    }
    [super viewWillAppear:animated];

}

- (void) addBookmark {
	
    NSLog(@"adding bookmark");
    [ModuleBookmark addBookmark:[self.detailItem valueForKey:@"name"]];
    [self activateTrashButton];
    NSLog(@"items %@", self.toolbarItems);
    
}

- (void) removeBookmark {
	
    NSLog(@"removing bookmark");
    [ModuleBookmark removeBookmark:[self.detailItem valueForKey:@"name"]];
    [self activateBookmarkButton];
    
}

- (void) activateBookmarkButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemBookmarks target:self action:@selector(addBookmark)];  
    self.navigationItem.rightBarButtonItem = item;

}

- (void) activateTrashButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash target:self action:@selector(removeBookmark)];    
    self.navigationItem.rightBarButtonItem = item;

}

@end
