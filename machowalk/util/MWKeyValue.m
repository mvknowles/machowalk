//
//  MWKeyValue.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWKeyValue.h"

@implementation MWKeyValue
@synthesize key;
@synthesize value;
@synthesize formatString;

-(instancetype)init:(NSString*)key value:(NSNumber*)value {
    self.key = key;
    self.value = value;
    return self;
}

-(instancetype)init:(NSString*)key value:(NSNumber*)value withFormat:(NSString*)format {
    self = [self init:key value:value];
    self.formatString = format;
    return self;
}

-(NSString*)description {
    /*if (self.formatString != nil) {
        return [NSString stringWithFormat:self.formatString, self.key, self.value.longLongValue];
    }*/
    return [NSString stringWithFormat:@"%@: %#llx", self.key, self.value.longLongValue];
}

-(NSObject*)normalizerOverride {
    return [NSArray arrayWithObjects:self.key, self.value, nil];
}
@end
