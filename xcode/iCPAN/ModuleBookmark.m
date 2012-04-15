//
//  ModuleBookmark.m
//  iCPAN
//
//  Created by Alders Olaf on 12-03-21.
//  Copyright (c) 2012 wundersolutions.com. All rights reserved.
//

#import "ModuleBookmark.h"

@implementation ModuleBookmark

+ (NSDictionary *)getBookmarks {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if([prefs dictionaryForKey:@"bookmarks"] == nil) {
		NSDictionary *bookmarks = [[NSDictionary alloc] init];
        [prefs setObject:bookmarks forKey:@"bookmarks"];
		[prefs synchronize];        
		return bookmarks;
	} else {
		return [prefs dictionaryForKey:@"bookmarks"];
	}
	
}

+ (BOOL)isBookmarked:(NSString *)moduleName {
    
	NSDictionary *bookmarks = [ModuleBookmark getBookmarks];
    NSLog(@"module name %@ %@", moduleName, bookmarks);
	
    if ([bookmarks objectForKey:moduleName]) {
        return 1;
	}
    	
	return 0;
}



@end
