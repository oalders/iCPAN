//
//  DetailViewController_iPad.h
//  iCPAN
//
//  Created by Olaf Alders on 11-05-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface DetailViewController_iPad : DetailViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
}

@property (nonatomic, strong) UIPopoverController *popoverController;

@end
