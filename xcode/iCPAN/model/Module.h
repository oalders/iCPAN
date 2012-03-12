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
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * abstract;
@property (nonatomic, strong) Distribution * distribution;
@property (nonatomic, strong) Pod * pod;

@end
