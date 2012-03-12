//
//  DetailViewController.h
//  iCPAN
//
//  Created by Olaf Alders on 11-05-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module.h"

@class GenericViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate,UIWebViewDelegate> {
    UIWebView *webView;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *stopButton;
}


@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, weak) IBOutlet GenericViewController *genericViewController;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) Module *detailItem;

/* UIWebView Navigation */
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopButton;

@end
