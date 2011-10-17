//
//  BookmarkController.h
//  iCPAN
//
//  Created by Olaf Alders on 11-10-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BookmarkController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tv;
}

@property (nonatomic, retain) IBOutlet UITableView *tv;

@end
