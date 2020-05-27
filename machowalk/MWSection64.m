//
//  MWSection64.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#include "mach-o/loader.h"
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSection64.h"

@implementation MWSection64
@synthesize value;
@synthesize sectionName;
@synthesize segmentName;

- (void)process {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct section_64)];
    debug(@"MWSection64: sectname: %s segname: %s\n", self.value->sectname, self.value->segname);
    
    self.segmentName = [NSString stringWithUTF8String:self.value->segname];
    self.sectionName = [NSString stringWithUTF8String:self.value->sectname];

    self.rawStruct = @[
        MAP_STRUCT(section_64, addr),
        MAP_STRUCT(section_64, size),
        MAP_STRUCT(section_64, offset),
        MAP_STRUCT(section_64, align),
        MAP_STRUCT(section_64, reloff),
        MAP_STRUCT(section_64, nreloc),
        MAP_STRUCT(section_64, flags),
        MAP_STRUCT(section_64, reserved1),
        MAP_STRUCT(section_64, reserved2),
        MAP_STRUCT(section_64, reserved3)
    ];
}

-(NSString*)description {
    return [[NSString alloc] initWithFormat:@"Section name: %s (in %s)\n%@",self.value->sectname, self.value->segname, [self origStruct]];
}
@end
