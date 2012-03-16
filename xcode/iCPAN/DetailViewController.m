//
//  DetailViewController.m
//  iCPAN
//
//  Created by Olaf Alders on 11-05-17.
//  Copyright 2011 wundersolutions.com. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchViewController_iPad.h"
#import "iCPANAppDelegate.h"
#import "Module.h"
#import "GRMustache.h"

@interface DetailViewController ()
@property (nonatomic, strong) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize toolbar=_toolbar;
@synthesize detailItem=_detailItem;
@synthesize detailDescriptionLabel=_detailDescriptionLabel;
@synthesize popoverController=_myPopoverController;
@synthesize genericViewController=_genericViewController;

@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;
@synthesize stopButton;
@synthesize webView;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(Module *)managedObject
{
	if (_detailItem != managedObject) {
		_detailItem = managedObject;
		
        // Update the view.
        [self configureView];
	}
    
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }		
}

- (void)configureView
{
    
    // Basically, we'll initiate the page load here, but we'll write the page to disk later
    // This method will only ever be called when the user selects a module from the table
    // in the GenericView

    NSString *name = [self.detailItem valueForKey:@"name"];
    iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    
    name = [name stringByReplacingOccurrencesOfString:@"::" withString:@"-"];
    name = [name stringByAppendingString:@".html"];
    
    NSURL *podURL = [[del podURL] URLByAppendingPathComponent:@"/"];
    NSURL *url = [NSURL URLWithString:name relativeToURL:podURL];
    
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    NSLog(@"about to load webview: ==============================================");
	[webView loadRequest:requestObj];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"detail view will appear");
    backButton.enabled = FALSE;
    forwardButton.enabled = FALSE;
    refreshButton.enabled = FALSE;
    stopButton.enabled = FALSE;

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"detail view did appear");
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"view will disappear");
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


// Called each time a rotation of the device is accomplished
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // CHECK: LANDSCAPE
    if ( (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) )
    {
        webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, 703, webView.frame.size.height);
    }
    // CHECK: PORTRAIT
    else
    {
        webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, 768, webView.frame.size.height);
    }
}

#pragma mark - Loading webView

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {		
	
    NSLog(@"viewDidLoad");
    
	// allow users to pinch/zoom.  also scales the page by default
	webView.scalesPageToFit = YES;
		
	// Override point for customization after application launch
	[super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSLog(@"shouldStartLoadWithRequest");
    
	iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    
	NSURL *url = [request URL];
	NSString *path = [url relativePath];

	NSLog(@"path: %@", path );

    
	if ([[url absoluteString] rangeOfString:@"http://"].location == NSNotFound ) {
        
        NSLog(@"Offline page view ------------------------------------------");
        // This is an offline page view. We need to handle all of the details.
        //
		path = [path stringByReplacingOccurrencesOfString:[del podDir] withString:@""];
		path = [path stringByReplacingOccurrencesOfString:@"/" withString:@""]; // too many slashes
		path = [path stringByReplacingOccurrencesOfString:@"-" withString:@"::"];
		path = [path stringByReplacingOccurrencesOfString:@".html" withString:@""];
		
		NSLog(@"module to search for: %@", path);
		
		NSManagedObjectContext *moc = [del managedObjectContext]; 
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
			NSLog(@"results for single module search %@", module.name );
						
			self.title = module.name;
			//self.currentlyViewing = module.name;
			//NSInteger is_bookmarked = [del isBookmarked:path];
			/*if ( is_bookmarked == 1 ) {
				[self removeBookmarkButton];
			}
			else {
				[self addBookmarkButton];
			}
            */
			
			NSString *fileName = module.name;
			fileName = [fileName stringByReplacingOccurrencesOfString:@"::" withString:@"-"];
			fileName = [fileName stringByAppendingString:@".html"];
            NSString *podPath = [[del podDir] stringByAppendingPathComponent:fileName];
            
			if ( ![[NSFileManager defaultManager] fileExistsAtPath:podPath] ) {
                
                NSString *tmplFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"template.html"];
                NSString *text = [GRMustacheTemplate renderObject:module fromContentsOfFile: tmplFile error:nil];
                //NSLog(@"testing pod: %@", [[module distribution] version]);
                [text writeToFile:podPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                NSLog(@"template file %@", tmplFile);
			}
            else {
                NSLog(@"page exists at %@", podPath);
            }
        
        }
		else {
            NSLog(@"module not found: %@", path);
			self.navigationItem.rightBarButtonItem = nil;
			self.title = @"404: Page Not Found";
		}
        refreshButton.enabled = FALSE;
        stopButton.enabled = FALSE;
	}
	else {
		// we are now online
		self.navigationItem.rightBarButtonItem = nil;
		self.title = [url absoluteString];
        refreshButton.enabled = TRUE;
        stopButton.enabled = TRUE;
    }
    
	return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)mwebView {
    backButton.enabled = (webView.canGoBack);
    forwardButton.enabled = (webView.canGoForward);
}


- (void)webViewDidFinishLoad:(UIWebView *)mwebView {
    backButton.enabled = (webView.canGoBack);
    forwardButton.enabled = (webView.canGoForward);
    
    // CHECK: LANDSCAPE
    if ( (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) )
    {
        self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, 703, self.webView.frame.size.height);
    }
    // CHECK: PORTRAIT
    else
    {
        self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, 768, self.webView.frame.size.height);
    }
    
}


#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Search";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = nil;
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.popoverController = nil;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


@end
