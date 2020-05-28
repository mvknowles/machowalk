//
//  MWSegment64Command.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSegmentCommand64.h"
#import "util/MWKeyValue.h"

@implementation MWSegmentCommand64
@synthesize sections;
@synthesize segmentName;

- (void)subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct segment_command_64)];
    
    sections = [[NSMutableArray alloc] init];
    self.segmentName = [NSString stringWithUTF8String:self.value->segname];
    
    // the sections immediately follow the segment
    // TODO: check for which MH_ types this is true
    for (int i=0; i < self.value->nsects; i++) {
        MWSection64 *section = [[MWSection64 alloc] init:self.machOFile];
        [section process];
        [sections addObject:section];
        debug(@"%@", section, NULL);
    }
    
    self.rawStruct = @[
        MAP_STRUCT(segment_command_64, cmd),
        MAP_STRUCT(segment_command_64, cmdsize),
        MAP_STRUCT(segment_command_64, vmaddr),
        MAP_STRUCT(segment_command_64, vmsize),
        MAP_STRUCT(segment_command_64, fileoff),
        MAP_STRUCT(segment_command_64, filesize),
        MAP_STRUCT(segment_command_64, maxprot),
        MAP_STRUCT(segment_command_64, initprot),
        MAP_STRUCT(segment_command_64, nsects),
        MAP_STRUCT(segment_command_64, flags)
    ];
}

-(NSString*) description {
    return [[NSString alloc] initWithFormat:@"Segment name: %s\n%@",self.value->segname, [self rawStruct]];
}
@end
