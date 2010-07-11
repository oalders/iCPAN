//
//  Module.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-04-26.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

#import "Author.h"

@class Author;

@interface Module :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * pod;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * review_count;
@property (nonatomic, retain) Author * Authors;

@end



