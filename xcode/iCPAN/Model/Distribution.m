//
//  Distribution.m
//  iCPAN
//
//  Created by Olaf Alders on 11-06-07.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import "Distribution.h"
#import "Author.h"
#import "Module.h"


@implementation Distribution
@dynamic release_date;
@dynamic version;
@dynamic name;
@dynamic abstract;
@dynamic modules;
@dynamic author;

- (void)addModulesObject:(Module *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"modules" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"modules"] addObject:value];
    [self didChangeValueForKey:@"modules" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeModulesObject:(Module *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"modules" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"modules"] removeObject:value];
    [self didChangeValueForKey:@"modules" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addModules:(NSSet *)value {    
    [self willChangeValueForKey:@"modules" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"modules"] unionSet:value];
    [self didChangeValueForKey:@"modules" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeModules:(NSSet *)value {
    [self willChangeValueForKey:@"modules" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"modules"] minusSet:value];
    [self didChangeValueForKey:@"modules" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



@end
