//
//  Module.h
//  iCPAN
//
//  Created by Olaf Alders on 11-06-07.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Module : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * pod;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) NSManagedObject * distribution;

@property (nonatomic, retain) NSString * path;

@end
