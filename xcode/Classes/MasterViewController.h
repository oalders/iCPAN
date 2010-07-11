//
//  MasterViewController.h
//
//  Created by Olaf Alders on 10-04-08.
//  Copyright 2010 wundersolutions.com. All rights reserved.
//

@interface MasterViewController : UIViewController <UIWebViewDelegate> {
	
    UIWebView *masterWebView;
	NSString *currentlyViewing;
}

@property (nonatomic, retain) IBOutlet UIWebView *masterWebView;
@property (nonatomic, retain) NSString *currentlyViewing;

@end
