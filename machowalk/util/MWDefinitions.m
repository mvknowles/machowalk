//
//  MWDefinitions.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWDefinitions.h"

@implementation MWDefinitions
@synthesize path;
@synthesize mappings;

+ (instancetype)from:(NSString*)path with:(NSDictionary<NSNumber*,NSString*>*)mappings {
    return [[MWDefinitions alloc] init:path mappings:mappings];
}

- (instancetype)init:(NSString*)path mappings:(NSDictionary<NSNumber*,NSString*>*)mappings {
    self.path = path;
    self.mappings = mappings;
    return self;
}


- (MWDefinedNumber*)get:value {
    NSString *name = self.mappings[value];
    if (name == nil) {
        debug(@"ERROR: undefined name for path: %@ val:%@", path, value, nil);
        name = @"UNDEFINED";
    }
    
    return [[MWDefinedNumber alloc] init: value name:name headerFile:path];
}

- (NSMutableArray<MWDefinedNumber*>*)getFlags:(NSNumber*)flags {
    NSMutableArray<MWDefinedNumber*> *namedFlags = [NSMutableArray new];
    NSUInteger uniqueFlag = 0;
    
    for (NSNumber *n in self.mappings.allKeys) {
        uniqueFlag = n.unsignedIntValue & flags.unsignedIntValue;
        if (uniqueFlag > 0) {
            [namedFlags addObject:[self get: n]];
        }
    }
    return namedFlags;
}

@end

