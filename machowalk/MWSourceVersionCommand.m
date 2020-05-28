//
//  MWSourceVersionCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWSourceVersionCommand.h"
#import "util/MWKeyValue.h"

@implementation MWSourceVersionCommand
@synthesize version;
@synthesize versionParts;

-(void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct source_version_command)];
    
    // the version is packed as 24-bits, 10-bits, 10-bits, 10-bits, 10-bits
    self.versionParts = @[
        @(self.value->version >> 40),
        @((self.value->version >> 30) & 0x000003FF),
        @((self.value->version >> 20) & 0x000003FF),
        @((self.value->version >> 10) & 0x000003FF),
        @(self.value->version & 0x000003FF)
    ];
    
    self.rawStruct = @[
        MAP_STRUCT(source_version_command, cmd),
        MAP_STRUCT(source_version_command, cmdsize),
        MAP_STRUCT(source_version_command, version)
    ];
}
-(NSString*)version {
    return [self.versionParts componentsJoinedByString:@"."];
}
-(NSString*)description {
    return [self version];
}
@end
