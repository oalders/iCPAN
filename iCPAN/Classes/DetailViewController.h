//
//  DetailViewController.h
//  iCPAN
//
//  Created by Olaf Alders on 10-09-01.
//  Copyright wundersolutions.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    NSManagedObject *detailItem;
    UILabel *detailDescriptionLabel;

}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;

- (IBAction)insertNewObject:(id)sender;

@end
