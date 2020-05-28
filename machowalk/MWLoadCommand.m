//
//  MWLoadCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWLoadCommand.h"
#import "MWSymtabCommand.h"
#import "MWSegmentCommand64.h"
#import "MWDylibCommand.h"
#import "MWDyldInfoCommand.h"
#import "MWDysymtabCommand.h"
#import "MWUUIDCommand.h"
#import "MWBuildVersionCommand.h"
#import "MWSourceVersionCommand.h"
#import "MWLinkEditDataCommand.h"

@implementation MWLoadCommand
@synthesize preamble;
@synthesize loadCommandType;
@synthesize saveDataOffset;
static MWDefinitions *loadCommandTypes;

-(instancetype) init:(struct load_command*)preamble machOFile:(MWMachOFile*)machOFile {
    self = [super init:machOFile];
    self.preamble = preamble;
    return self;
}

- (void)subprocess {
    // optional override
}

-(void) process {
    self.saveDataOffset = [self.machOFile.chunker dataOffset];
    self.loadCommandType = [loadCommandTypes get:@(preamble->cmd)];

    [self subprocess];
    [self.machOFile.chunker setDataOffset:[super elementOffset] + preamble->cmdsize];
}

+(instancetype) createFromPreamble:(MWMachOFile*)machOFile {
    struct load_command *preamble;
    preamble = [[machOFile chunker] dataChunk:sizeof(struct load_command) increment:false];
    
    MWLoadCommand *n;

    switch (preamble->cmd) {
        case LC_SYMTAB:
            n = [[MWSymtabCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_SEGMENT_64:
            n = [[MWSegmentCommand64 alloc] init:preamble machOFile:machOFile];
            break;
        case LC_LOAD_DYLIB:
        case LC_LOAD_WEAK_DYLIB:
        case LC_REEXPORT_DYLIB:
        case LC_ID_DYLIB:
            n = [[MWDylibCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_DYLD_INFO:
        case LC_DYLD_INFO_ONLY:
                n = [[MWDyldInfoCommand alloc] init:preamble machOFile:machOFile];
                break;
        case LC_DYSYMTAB:
            n = [[MWDysymtabCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_UUID:
            n = [[MWUUIDCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_BUILD_VERSION:
            n = [[MWBuildVersionCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_SOURCE_VERSION:
            n = [[MWSourceVersionCommand alloc] init:preamble machOFile:machOFile];
            break;
        case LC_SEGMENT_SPLIT_INFO:
        case LC_FUNCTION_STARTS:
        case LC_CODE_SIGNATURE:
        case LC_DATA_IN_CODE:
            n = [[MWLinkEditDataCommand alloc] init:preamble machOFile:machOFile];
            break;
        default:
            n = [[MWLoadCommand alloc] init:preamble machOFile:machOFile];
            debug(@"Unhandled load cmd %x\n", preamble->cmd, nil);
            break;
    }

    return n;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"Load command: %@", self.loadCommandType];
}

+(void)initialize {
    loadCommandTypes = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings: @{
        MAP_DEFINE(LC_SEGMENT),
        MAP_DEFINE(LC_SYMTAB),
        MAP_DEFINE(LC_SYMSEG),
        MAP_DEFINE(LC_THREAD),
        MAP_DEFINE(LC_UNIXTHREAD),
        MAP_DEFINE(LC_LOADFVMLIB),
        MAP_DEFINE(LC_IDFVMLIB),
        MAP_DEFINE(LC_IDENT),
        MAP_DEFINE(LC_FVMFILE),
        MAP_DEFINE(LC_PREPAGE),
        MAP_DEFINE(LC_DYSYMTAB),
        MAP_DEFINE(LC_LOAD_DYLIB),
        MAP_DEFINE(LC_ID_DYLIB),
        MAP_DEFINE(LC_LOAD_DYLINKER),
        MAP_DEFINE(LC_ID_DYLINKER),
        MAP_DEFINE(LC_PREBOUND_DYLIB),
        MAP_DEFINE(LC_ROUTINES),
        MAP_DEFINE(LC_SUB_FRAMEWORK),
        MAP_DEFINE(LC_SUB_UMBRELLA),
        MAP_DEFINE(LC_SUB_CLIENT),
        MAP_DEFINE(LC_SUB_LIBRARY),
        MAP_DEFINE(LC_TWOLEVEL_HINTS),
        MAP_DEFINE(LC_PREBIND_CKSUM),
        MAP_DEFINE(LC_LOAD_WEAK_DYLIB),
        MAP_DEFINE(LC_SEGMENT_64),
        MAP_DEFINE(LC_ROUTINES_64),
        MAP_DEFINE(LC_UUID),
        MAP_DEFINE(LC_RPATH),
        MAP_DEFINE(LC_CODE_SIGNATURE),
        MAP_DEFINE(LC_SEGMENT_SPLIT_INFO),
        MAP_DEFINE(LC_REEXPORT_DYLIB),
        MAP_DEFINE(LC_LAZY_LOAD_DYLIB),
        MAP_DEFINE(LC_ENCRYPTION_INFO),
        MAP_DEFINE(LC_DYLD_INFO),
        MAP_DEFINE(LC_DYLD_INFO_ONLY),
        MAP_DEFINE(LC_LOAD_UPWARD_DYLIB),
        MAP_DEFINE(LC_VERSION_MIN_MACOSX),
        MAP_DEFINE(LC_VERSION_MIN_IPHONEOS),
        MAP_DEFINE(LC_FUNCTION_STARTS),
        MAP_DEFINE(LC_DYLD_ENVIRONMENT),
        MAP_DEFINE(LC_MAIN),
        MAP_DEFINE(LC_DATA_IN_CODE),
        MAP_DEFINE(LC_SOURCE_VERSION),
        MAP_DEFINE(LC_DYLIB_CODE_SIGN_DRS),
        MAP_DEFINE(LC_ENCRYPTION_INFO_64),
        MAP_DEFINE(LC_LINKER_OPTION),
        MAP_DEFINE(LC_LINKER_OPTIMIZATION_HINT),
        MAP_DEFINE(LC_VERSION_MIN_TVOS),
        MAP_DEFINE(LC_VERSION_MIN_WATCHOS),
        MAP_DEFINE(LC_NOTE),
        MAP_DEFINE(LC_BUILD_VERSION),
        MAP_DEFINE(LC_DYLD_EXPORTS_TRIE),
        MAP_DEFINE(LC_DYLD_CHAINED_FIXUPS)
    }];
}
@end
