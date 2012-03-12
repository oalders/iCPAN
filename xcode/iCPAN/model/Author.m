//
//  Author.m
//  iCPAN
//
//  Created by Olaf Alders on 11-07-04.
//  Copyright (c) 2011 wundersolutions.com. All rights reserved.
//

#import "Author.h"
#import "Distribution.h"


@implementation Author
@dynamic email;
@dynamic name;
@dynamic pauseid;
@dynamic distributions;

- (void)addDistributionsObject:(Distribution *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"distributions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"distributions"] addObject:value];
    [self didChangeValueForKey:@"distributions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeDistributionsObject:(Distribution *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"distributions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"distributions"] removeObject:value];
    [self didChangeValueForKey:@"distributions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addDistributions:(NSSet *)value {    
    [self willChangeValueForKey:@"distributions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"distributions"] unionSet:value];
    [self didChangeValueForKey:@"distributions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeDistributions:(NSSet *)value {
    [self willChangeValueForKey:@"distributions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"distributions"] minusSet:value];
    [self didChangeValueForKey:@"distributions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
