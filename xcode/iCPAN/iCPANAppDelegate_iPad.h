//
//  iCPANAppDelegate_iPad.h
//  iCPAN
//
//  Created by Olaf Alders on 11-05-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCPANAppDelegate.h"

@class GenericViewController;

@class DetailViewController;

@interface iCPANAppDelegate_iPad : iCPANAppDelegate {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet GenericViewController *genericViewController;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
