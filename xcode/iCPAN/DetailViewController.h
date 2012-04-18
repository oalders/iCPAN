//
//  DetailViewController.h
//  iCPAN
//
//  Created by Alders Olaf on 12-03-16.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Module.h"


@interface DetailViewController : UIViewController <UIWebViewDelegate> {
    UIWebView       *podViewer;
    UIBarButtonItem *backButton;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *stopButton;
}


@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIWebView *podViewer;
@property (nonatomic, strong) Module *detailItem;

/* UIWebView Navigation */
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopButton;

-(void) configureView;

@end