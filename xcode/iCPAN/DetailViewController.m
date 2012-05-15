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

@synthesize backButton;
@synthesize bottomSpacerHeight;
@synthesize detailItem;
@synthesize detailDescriptionLabel;
@synthesize forwardButton;
@synthesize podViewer;
@synthesize refreshButton;
@synthesize stopButton;
@synthesize toolbar;

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

    iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    
    NSString *pageName = [self module2url:detailItem];
    NSLog(@"pageName %@", pageName);
    
    NSURL *podURL = [[del podURL] URLByAppendingPathComponent:@"/"];
    NSURL *url = [NSURL URLWithString:pageName relativeToURL:podURL];
    
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
	[podViewer loadRequest:requestObj];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    backButton.enabled    = FALSE;
    forwardButton.enabled = FALSE;
    refreshButton.enabled = FALSE;
    stopButton.enabled    = FALSE;
    
    [super viewWillAppear:animated];
}


#pragma mark - Loading webView

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {		
	
    NSLog(@"viewDidLoad");
    
	// allow users to pinch/zoom.  also scales the page by default
	podViewer.scalesPageToFit = YES;
    
	// Override point for customization after application launch
    podViewer.delegate = self;
	[super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSLog(@"shouldStartLoadWithRequest begins");
    
	iCPANAppDelegate *del = [[UIApplication sharedApplication] delegate];
    
	NSURL *url = [request URL];
        
	if ([[url absoluteString] rangeOfString:@"http://"].location == NSNotFound ) {
        
        NSLog(@"Offline page view ------------------------------------------");
        // This is an offline page view. We need to handle all of the details.
        //
        NSString *path = [self url2module:[url lastPathComponent]];
		
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
            
            NSString *fileName = [self module2url:module];
            NSString *podPath = [[del podDir] stringByAppendingPathComponent:fileName];
            
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
            // Optional - label.text = @"NavLabel";
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:[UIColor whiteColor]];
            [label sizeToFit];
            [label setText:module.name];
            [self.navigationController.navigationBar.topItem setTitleView:label];

			if ( ![[NSFileManager defaultManager] fileExistsAtPath:podPath] ) {
                
                NSLog(@"creating file at %@ with height %@", podPath, bottomSpacerHeight);
                NSDictionary *templateVars = [ [NSDictionary alloc] initWithObjectsAndKeys: module, @"module", bottomSpacerHeight, @"bottomSpacerHeight", nil];
                
                NSString *tmplFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"template.html"];
                NSString *text = [GRMustacheTemplate renderObject:templateVars fromContentsOfFile: tmplFile error:nil];                
                NSError *writeError = nil;
                
                [text writeToFile:podPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
                NSLog(@"template file %@", tmplFile);
                if (writeError) {
                    NSLog(@"there was an error writing the file %@", writeError);
                }
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
    backButton.enabled    = (webView.canGoBack);
    forwardButton.enabled = (webView.canGoForward);
}

-(NSString*)url2module:(NSString *)pageName {
    pageName = [pageName stringByReplacingOccurrencesOfString:@"__" withString:@"::"];
    pageName = [pageName stringByReplacingOccurrencesOfString:@".html" withString:@""];
    return pageName;
}

-(NSString*)module2url:(Module *)Module {
    NSString *name = Module.name;
    name = [name stringByReplacingOccurrencesOfString:@"::" withString:@"__"];
    name = [name stringByAppendingString:@".html"];
    return name;
}

@end
