//
//  MWMachHeader64.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWMachHeader64.h"
#import "util/MWDefinitions.h"

@implementation MWMachHeader64
static MWDefinitions *magicDefs;
static MWDefinitions *fileTypeDefinitions;
@synthesize fileType;
@synthesize magic;

+ (void)initialize {
    if (self != [MWMachHeader64 class]) {
        return;
    }
    
    fileTypeDefinitions = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(MH_OBJECT),
        MAP_DEFINE(MH_EXECUTE),
        MAP_DEFINE(MH_FVMLIB),
        MAP_DEFINE(MH_DYLIB)
    }];
    
    magicDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(MH_MAGIC_64),
        MAP_DEFINE(MH_CIGAM_64),
        MAP_DEFINE(MH_MAGIC),
        MAP_DEFINE(MH_CIGAM)
    }];
}


- (void) process {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct mach_header_64)];

    if (self.value->magic != MH_MAGIC_64) {
        NSLog(@"Not 64-big mach");
        return;
    }
    [self.machOFile setHeader:self];
    self.fileType = [fileTypeDefinitions get:@(self.value->filetype)];
    self.magic = [magicDefs get:@(self.value->magic)];
    
    self.machOFile.loadCommands = [[NSMutableArray alloc] init];
    // loop over each load command
    for (int i = 0; i < self.value->ncmds; i++) {
        MWLoadCommand *lc = [MWLoadCommand createFromPreamble:self.machOFile];
        [lc process];
        [self.machOFile.loadCommands addObject:lc];
        debug(@"%@", lc, NULL);
    }

    self.rawStruct = @[
        MAP_STRUCT(mach_header_64, magic),
        MAP_STRUCT(mach_header_64, cputype),
        MAP_STRUCT(mach_header_64, cpusubtype),
        MAP_STRUCT(mach_header_64, filetype),
        MAP_STRUCT(mach_header_64, ncmds),
        MAP_STRUCT(mach_header_64, sizeofcmds),
        MAP_STRUCT(mach_header_64, flags),
        MAP_STRUCT(mach_header_64, reserved)
    ];
    
}

- (NSUInteger)headerLength {
    return sizeof(self.value);
}

- (NSString*)description {
    return [NSString stringWithFormat:@"filetype: %@", self.fileType];
}

@end
