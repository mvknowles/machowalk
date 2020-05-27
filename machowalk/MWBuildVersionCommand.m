//
//  MWBuildCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWBuildVersionCommand.h"
#import "MWKeyValue.h"
#import "MWDefinitions.h"

@implementation MWBuildTool
@synthesize name;
@synthesize version;
-(instancetype)init:(NSObject*)name version:(NSNumber*)version {
    self.name = name;
    self.version = version;
    return self;
}
-(NSString*)description {
    return [NSString stringWithFormat:@"%@: %@",self.name,self.version];
}
@end

@implementation MWBuildVersionCommand
static MWDefinitions *platformDefs;
static MWDefinitions *toolDefs;
@synthesize platformDef;
@synthesize buildTools;

+(void)initialize {
    if (self != [MWBuildVersionCommand class]) {
        return;
    }

    platformDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(PLATFORM_MACOS),
        MAP_DEFINE(PLATFORM_IOS),
        MAP_DEFINE(PLATFORM_TVOS),
        MAP_DEFINE(PLATFORM_WATCHOS),
        MAP_DEFINE(PLATFORM_BRIDGEOS),
        MAP_DEFINE(PLATFORM_MACCATALYST),
        MAP_DEFINE(PLATFORM_IOSSIMULATOR),
        MAP_DEFINE(PLATFORM_TVOSSIMULATOR),
        MAP_DEFINE(PLATFORM_WATCHOSSIMULATOR),
        MAP_DEFINE(PLATFORM_DRIVERKIT)
    }];
    
    toolDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(TOOL_CLANG),
    	MAP_DEFINE(TOOL_SWIFT),
        MAP_DEFINE(TOOL_LD)
    }];
}

-(void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct build_version_command)];
    
    self.platformDef = [platformDefs get:@(self.value->platform)];
    self.buildTools = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.value->ntools; i++) {
        struct build_tool_version *toolVersion;
        MWBuildTool *tool;
        
        toolVersion = [self.machOFile.chunker dataChunk:sizeof(struct build_version_command)];
        tool = [[MWBuildTool alloc] init];
        tool.name = [[toolDefs get:@(toolVersion->tool)] name];
        tool.version = @(toolVersion->version);
        
        if (tool.name == nil) {
            tool.name = [NSNumber numberWithUnsignedInt:toolVersion->tool];
        }
        [self.buildTools addObject:tool];
    }
    
    self.rawStruct = @[
        MAP_STRUCT(build_version_command, cmd),
        MAP_STRUCT(build_version_command, cmdsize),
        MAP_STRUCT(build_version_command, platform),
        MAP_STRUCT(build_version_command, minos),
        MAP_STRUCT(build_version_command, sdk),
        MAP_STRUCT(build_version_command, ntools)
    ];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"Platform: %@\n%@\nBuild tools:%@",self.platformDef, self.rawStruct, self.buildTools];
}
@end
