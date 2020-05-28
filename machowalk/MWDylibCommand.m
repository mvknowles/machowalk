//
//  MWDylibCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWDylibCommand.h"

@implementation MWDylibCommand
@synthesize name;
@synthesize currentVersion;
@synthesize currentVersionParts;
@synthesize compatibilityVersion;
@synthesize compatibilityVersionParts;

-(void) subprocess {
    //self.value = bufChunk(sizeof(struct dylib_command));
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct dylib_command) increment:true];
    
    NSUInteger maxNameLength = self.value->cmdsize - self.value->dylib.name.offset;
    
    //the name field can be padded with zeros, so the number of chars read may not = maxNameLength
    self.name = [self.machOFile.chunker readUTF8StringWithMaxLength:maxNameLength];
    
    self.currentVersionParts = @[
        @((self.value->dylib.current_version >> 24) & 0x000000FF),
        @((self.value->dylib.current_version >> 16) & 0x000000FF),
        @((self.value->dylib.current_version >> 8) & 0x000000FF),
        @(self.value->dylib.current_version & 0x000000FF)
    ];

    self.compatibilityVersionParts = @[
        @((self.value->dylib.compatibility_version >> 24) & 0x000000FF),
        @((self.value->dylib.compatibility_version >> 16) & 0x000000FF),
        @((self.value->dylib.compatibility_version >> 8) & 0x000000FF),
        @(self.value->dylib.compatibility_version & 0x000000FF)
    ];
    
    
    self.rawStruct = @[
        MAP_STRUCT(dylib_command, cmd),
        MAP_STRUCT(dylib_command, cmdsize),
        MAP_STRUCT(dylib_command, dylib.timestamp),
        MAP_STRUCT(dylib_command, dylib.current_version),
        MAP_STRUCT(dylib_command, dylib.compatibility_version),
    ];
    
    //return self;
}

-(NSString*)currentVersion {
    return [self.currentVersionParts componentsJoinedByString:@"."];
}

-(NSString*)compatibilityVersion {
    return [self.compatibilityVersionParts componentsJoinedByString:@"."];
}

-(NSString*) description {
    return [NSString stringWithFormat:@"%@ Dylib name: %@ current_version: %@ compatibility_version: %@\n", self.loadCommandType, self.name, self.currentVersion, self.compatibilityVersion];
}
@end
