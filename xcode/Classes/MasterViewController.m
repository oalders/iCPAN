//
//  MasterViewController.m
//
//  Created by Olaf Alders on 10-04-08.
//  Copyright 2010 wundersolutions.com. All rights reserved.
//

#import "MasterViewController.h"
#import "iCPANAppDelegate.h"
#import "BookmarksViewController.h"

@implementation MasterViewController

@synthesize masterWebView;
@synthesize currentlyViewing;


- (void)removeBookmarkButton {
	//UIBarButtonItem *removeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(remove:)];
    UIBarButtonItem *removeButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_trash.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(remove:)];
	self.navigationItem.rightBarButtonItem = removeButtonItem;
	[removeButtonItem release]; 
}

- (void)addBookmarkButton {
	//UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_bookmark_add.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
	self.navigationItem.rightBarButtonItem = addButtonItem;
	[addButtonItem release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {		
	
	iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	//NSLog(@"looking for: %@", appDelegate.cpanpod);
	
    NSString *podPath = [appDelegate.cpanpod stringByAppendingString:appDelegate.selectedModule.path];
	NSURL *url = [NSURL fileURLWithPath:podPath];
	
	//NSLog(@"url: %@", url);
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[masterWebView loadRequest:requestObj];

	// allow users to pinch/zoom.  also scales the page by default
	masterWebView.scalesPageToFit = YES;
	
	[[NSUserDefaults standardUserDefaults] setValue:appDelegate.selectedModule.name forKey:@"last_module"];
	
	// Override point for customization after application launch
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {

    iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray *recentlyViewed = appDelegate.getRecentlyViewed;
    
    NSMutableArray *mutableRecentlyViewed = [[recentlyViewed mutableCopy] autorelease];
    
    if ([[[self parentViewController] title] isEqualToString:@"Search Module Navigation Controller"] && ![mutableRecentlyViewed containsObject:self.title]) {
        if ([prefs integerForKey:@"recent_modules"] > 0 && [mutableRecentlyViewed count] >= [prefs integerForKey:@"recent_modules"]) {
            for ( int i = [mutableRecentlyViewed count] - [prefs integerForKey:@"recent_modules"]; i >= 0; i--) {
                [mutableRecentlyViewed removeObjectAtIndex:0];        
            }
        }
        [mutableRecentlyViewed addObject:self.title];
        [prefs setObject:mutableRecentlyViewed forKey:@"recentlyViewed"];
        [prefs synchronize];
    }

}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];

	NSURL *url = [request URL];
	NSString *path = [url relativePath];

	//NSLog(@"relativePath: %@", [url relativePath]);
	//NSLog(@"absoluteString: %@", [url absoluteString]);
	//NSLog(@"baseURL: %@", [url baseURL]);	
	
	if ([[url absoluteString] rangeOfString:@"http://"].location == NSNotFound) {
					
		path = [path stringByReplacingOccurrencesOfString:[appDelegate cpanpod] withString:@""];
		path = [path stringByReplacingOccurrencesOfString:@"-" withString:@"::"];
		path = [path stringByReplacingOccurrencesOfString:@".html" withString:@""];
		
		//NSLog(@"module to search for: %@", path);
		
		NSManagedObjectContext *moc = [appDelegate managedObjectContext]; 
		NSFetchRequest *req = [[NSFetchRequest alloc] init];
		[req setEntity:[NSEntityDescription entityForName:@"Module" inManagedObjectContext:moc]];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", path];
		[req setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *results = [moc executeFetchRequest:req error:&error];
			
		if (error) {
			// Replace this implementation with code to handle the error appropriately.
				
			NSLog(@"there has been an error");
			NSLog(@"fetchedResultsController error %@, %@", error, [error userInfo]);
			//exit(1);
		} 


		if ( results.count > 0 ) {
			
			Module *module = [results objectAtIndex:0];
			//NSLog(@"results for single module search %@", module.name );
			
			//NSLog(@"This is a local URL");
			
			self.title = module.name;
			self.currentlyViewing = module.name;
			NSInteger is_bookmarked = [appDelegate isBookmarked:path];
			if ( is_bookmarked == 1 ) {
				[self removeBookmarkButton];
			}
			else {
				[self addBookmarkButton];
			}
			
			NSString *podPath = appDelegate.cpanpod;
			NSString *fileName = module.name;
			fileName = [fileName stringByReplacingOccurrencesOfString:@"::" withString:@"-"];
			fileName = [fileName stringByAppendingString:@".html"];
			podPath = [podPath stringByAppendingString:fileName];
					
			if ( ![[NSFileManager defaultManager] fileExistsAtPath:podPath] ) {
				//NSLog(@"pod will be written to: %@", podPath);
				NSData* pod_data = [module.pod dataUsingEncoding:NSUTF8StringEncoding];
				[pod_data writeToFile:podPath atomically:YES];
			}
		}
		else {
			self.navigationItem.rightBarButtonItem = nil;
			self.title = @"404: Page Not Found";
		}
		
		[req release];
	}
	else {
		// we are now online
		self.navigationItem.rightBarButtonItem = nil;
		self.title = [url absoluteString];
	}
	
	//NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:appDelegate.cpanpod];
	//NSLog(@"contents %@", dirContents);

	return TRUE;
}

- (void)add:(id)sender {
	
	NSString *msg = [NSString stringWithFormat:@"Add %@ to your bookmarks?", currentlyViewing];
	UIAlertView *bookmarkAlert = [[UIAlertView alloc] initWithTitle: @"Add Bookmark" message: msg delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"OK", nil];

	[bookmarkAlert show];
	[bookmarkAlert release];

}

- (void)remove:(id)sender {
	
	//NSLog(@"currently viewing", currentlyViewing);
	NSString *msg = [NSString stringWithFormat:@"Remove %@ from your bookmarks?", currentlyViewing];
	
	UIAlertView *bookmarkAlert = [[UIAlertView alloc] initWithTitle: @"Remove Bookmark" message: msg delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"OK", nil];
	[bookmarkAlert show];
	[bookmarkAlert release];

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

	// the user clicked OK
	if (buttonIndex == 1)
	{
		iCPANAppDelegate *appDelegate = (iCPANAppDelegate*)[[UIApplication sharedApplication] delegate];
				
		NSDictionary *bookmarks = appDelegate.getBookmarks;			
		NSMutableDictionary *mutable_bookmarks = [[bookmarks mutableCopy] autorelease];
        
		if ( [appDelegate isBookmarked:currentlyViewing] ) {
			[mutable_bookmarks removeObjectForKey:currentlyViewing];
			[self addBookmarkButton];
        }
		else {
            [mutable_bookmarks setValue:currentlyViewing forKey:currentlyViewing];
			[self removeBookmarkButton]; 		
		}
        
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:mutable_bookmarks forKey:@"bookmarks"];
        [prefs synchronize];

	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
    [masterWebView release];
	[currentlyViewing release];
    
    [super dealloc];
}


@end
