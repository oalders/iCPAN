//
//  Distribution.h
//  iCPAN
//
//  Created by Olaf Alders on 11-07-04.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Module;

@interface Distribution : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * release_date;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * release_name;
@property (nonatomic, retain) Author * author;
@property (nonatomic, retain) NSSet* modules;

@end
