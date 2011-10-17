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
}

@property (nonatomic, retain) IBOutlet UITableView *tv;

@end