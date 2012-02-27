//
//  iCPANAppDelegate_iPhone.h
//  iCPAN
//
//  Created by Olaf Alders on 11-03-31.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCPANAppDelegate.h"

@interface iCPANAppDelegate_iPhone : iCPANAppDelegate {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
