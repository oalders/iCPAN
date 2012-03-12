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

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, strong) IBOutlet GenericViewController *genericViewController;

@property (nonatomic, strong) IBOutlet DetailViewController *detailViewController;

@end
