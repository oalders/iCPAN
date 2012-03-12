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
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate * release_date;
@property (nonatomic, strong) NSString * abstract;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) NSString * release_name;
@property (nonatomic, strong) Author * author;
@property (nonatomic, strong) NSSet* modules;

@end
