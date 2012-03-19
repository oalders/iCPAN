//
//  DetailViewController.m
//  iCPAN
//
//  Created by Alders Olaf on 12-03-16.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import "DetailViewController.h"
#import "iCPANAppDelegate.h"
#import "Module.h"
#import "GRMustache.h"

@implementation DetailViewController

@synthesize toolbar;
@synthesize detailItem;
@synthesize detailDescriptionLabel;

@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;
@synthesize stopButton;
@synthesize podViewer;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(Module *)managedObject
{
    NSLog(@"setDetailItem (shared)");

	if (detailItem != managedObject) {
		detailItem = managedObject;
		
        // Update the view.
        [self configureView];
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
    
	[podViewer loadRequest:requestObj];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    backButton.enabled = FALSE;
    forwardButton.enabled = FALSE;
    refreshButton.enabled = FALSE;
    stopButton.enabled = FALSE;
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
        podViewer.frame = CGRectMake(podViewer.frame.origin.x, podViewer.frame.origin.y, 703, podViewer.frame.size.height);
    }
    // CHECK: PORTRAIT
    else
    {
        podViewer.frame = CGRectMake(podViewer.frame.origin.x, podViewer.frame.origin.y, 768, podViewer.frame.size.height);
    }
}

#pragma mark - Loading webView

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {		
	
    NSLog(@"viewDidLoad");
    
	// allow users to pinch/zoom.  also scales the page by default
	podViewer.scalesPageToFit = YES;
    
	// Override point for customization after application launch
	[super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSLog(@"shouldStartLoadWithRequest begins");
    
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
    
    NSLog(@"shouldStartLoadWithRequest ends");
    
    
	return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    backButton.enabled = (webView.canGoBack);
    forwardButton.enabled = (webView.canGoForward);
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

@end
