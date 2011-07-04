//
//  Module.h
//  iCPAN
//
//  Created by Olaf Alders on 11-07-04.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Distribution, Pod;

@interface Module : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) Distribution * distribution;
@property (nonatomic, retain) Pod * pod;

@end
