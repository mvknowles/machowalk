//
//  MWMachElement.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWMachElement.h"

@implementation MWMachElement
@synthesize elementOffset;
@synthesize machOFile;
@synthesize origStruct;
@synthesize rawStruct;

- (instancetype)init:(MWMachOFile*)machOFile {
    self.machOFile = machOFile;
    self.elementOffset = [machOFile.chunker dataOffset];
    return self;
}

- (void)process {
    debug(@"ERROR: you should have overridden process");
}

-(NSDictionary<NSString*,NSObject*>*) origStruct {
    NSMutableDictionary<NSString*,NSObject*> *csd = [NSMutableDictionary new];
    
    for (MWKeyValue *item in self.rawStruct) {
        [csd setValue:item.value forKey:item.key];
    }
    return csd;
}

+(NSSet<NSString*>*)dontSerialize {
    return [NSSet setWithObjects:@"rawStruct", @"machOFile", nil];
}

@end
