//
//  iCPANAppDelegate_iPhone.m
//  iCPAN
//
//  Created by Olaf Alders on 11-03-31.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "iCPANAppDelegate_iPhone.h"
#import "SearchViewController_iPhone.h"

@implementation iCPANAppDelegate_iPhone

@synthesize tabBarController;
@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
    NSLog(@"did finish launching iPhone app");

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"did finish launching iPhone app");
    [window addSubview:tabBarController.view];
    return YES;

}


@end
