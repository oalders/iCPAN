//
//  Pod.h
//  iCPAN
//
//  Created by Olaf Alders on 11-07-04.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module;

@interface Pod : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) Module * module;

@end
