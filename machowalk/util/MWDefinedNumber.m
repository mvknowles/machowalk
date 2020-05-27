//
//  MWDefinedNumber.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWDefinedNumber.h"

@implementation MWDefinedNumber : NSObject
@synthesize name;
@synthesize headerFile;
@synthesize value;

- (instancetype)init:(NSNumber*)value name:(NSString*)name headerFile:(NSString*)headerFile {
    self.name = name;
    self.headerFile = headerFile;
    self.value = value;
    return self;
}

- (NSString*)debugDescription {
    return [NSString stringWithFormat:@"%@(%@): %@", self.name, self.headerFile, self.value];
}

- (NSString*)description {
    return [self.name description];
//    return [NSString stringWithFormat:@"%@: %@", self.name, self.value];
}

/*- (instancetype) init:
+ (NSString *)definitions {
  static NSDictionary *fooDict = nil;
  if (fooDict == nil) {
    // create dict
  }
  return fooDict;
}}*/

-(NSObject*)normalizerOverride {
    return name;
}

@end
