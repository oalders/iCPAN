// 
//  Module.m
//  iCPAN
//
//  Created by WunderSolutions.com on 10-04-26.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

#import "Module.h"


@implementation Module 

@dynamic author;
@dynamic name;
@dynamic version;
@dynamic path;
@dynamic pod;
@dynamic rating;
@dynamic review_count;
@dynamic Authors;

- (NSString *)path {
	
    NSString *path = [self.name stringByReplacingOccurrencesOfString:@"::" withString:@"-"];
    path = [path stringByAppendingString:@".html"];

    return path;

}

@end
