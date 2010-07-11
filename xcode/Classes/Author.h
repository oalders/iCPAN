//
//  Author.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-04-28.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

@class Module;

@interface Author :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pauseid;
@property (nonatomic, retain) NSSet* Modules;

@end


@interface Author (CoreDataGeneratedAccessors)
- (void)addModulesObject:(Module *)value;
- (void)removeModulesObject:(Module *)value;
- (void)addModules:(NSSet *)value;
- (void)removeModules:(NSSet *)value;

@end

