//
//  MWDyldInfoCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#include "mach-o/loader.h"
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWDyldInfoCommand.h"
#import "MWMachHeader64.h"

@implementation MWDyldInfoCommand
@synthesize exportedSymbols;
static MWDefinitions *bindOpcodeDefs;

+ (void)initialize {
    if (self != [MWDyldInfoCommand class]) {
        return;
    }
    bindOpcodeDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(BIND_OPCODE_DONE),
        MAP_DEFINE(BIND_OPCODE_SET_DYLIB_ORDINAL_IMM),
        MAP_DEFINE(BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB),
        MAP_DEFINE(BIND_OPCODE_SET_DYLIB_SPECIAL_IMM),
        MAP_DEFINE(BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM),
        MAP_DEFINE(BIND_OPCODE_SET_TYPE_IMM),
        MAP_DEFINE(BIND_OPCODE_SET_ADDEND_SLEB),
        MAP_DEFINE(BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB),
        MAP_DEFINE(BIND_OPCODE_ADD_ADDR_ULEB),
        MAP_DEFINE(BIND_OPCODE_DO_BIND),
        MAP_DEFINE(BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB),
        MAP_DEFINE(BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED),
        MAP_DEFINE(BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB),
        MAP_DEFINE(BIND_OPCODE_THREADED)
    }];
}

- (void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct dyld_info_command)];
    
    debug(@"SUBPROC rebase %d\n", self.value->rebase_size);
    debug(@"SUBPROC bind %d\n", self.value->bind_size);
    debug(@"SUBPROC weak %d\n", self.value->weak_bind_size);
    debug(@"SUBPROC lazy %d\n", self.value->lazy_bind_size);
    debug(@"SUBPROC export %x\n", self.value->export_off);
    debug(@"SUBPROC export %d\n", self.value->export_size);

    [self.machOFile.chunker setDataOffset:self.value->export_off];
    self.exportedSymbols = [[NSMutableArray alloc] init];
    [self walkExports:nil];
    
    self.rawStruct = @[
        MAP_STRUCT(dyld_info_command, cmd),
        MAP_STRUCT(dyld_info_command, cmdsize),
        MAP_STRUCT(dyld_info_command, rebase_off),
        MAP_STRUCT(dyld_info_command, rebase_size),
        MAP_STRUCT(dyld_info_command, bind_off),
        MAP_STRUCT(dyld_info_command, bind_size),
        MAP_STRUCT(dyld_info_command, weak_bind_off),
        MAP_STRUCT(dyld_info_command, weak_bind_size),
        MAP_STRUCT(dyld_info_command, lazy_bind_off),
        MAP_STRUCT(dyld_info_command, lazy_bind_size),
        MAP_STRUCT(dyld_info_command, export_off),
        MAP_STRUCT(dyld_info_command, export_size)
    ];
}

- (void) walkExports:(NSString *)prevSymbol {
    uint8_t edgeCount = 0;
    uint64_t nodeSize;
    //NSLog(@"Symbol so far: %@", prevSymbol);
    
    nodeSize = [self.machOFile.chunker readUleb128];
    
    if (nodeSize > 0) {
        uint8_t flags = [self.machOFile.chunker readByte];
        
        MWExportedSymbol *exportedSymbol = [MWExportedSymbol createFromFlags:flags symbol:prevSymbol machOFile:self.machOFile];
        
        [self.exportedSymbols addObject:exportedSymbol];
    }

    edgeCount = [self.machOFile.chunker readByte];
    //NSLog(@"EDGE COUNT: %d, nodeSize: %llu", edgeCount, nodeSize);
    for (int i=0; i < edgeCount; i++) {
        NSString *symbolPart;
        NSString *newSymbol;
        NSUInteger saveOffset;
        uint64_t childNodeOffset;

        // null-terminated UTF-8 byte sequence follows
        symbolPart = [self.machOFile.chunker readUTF8String];

        if (prevSymbol == nil) {
            newSymbol = symbolPart;
        } else {
            newSymbol = [NSString stringWithFormat:@"%@%@",prevSymbol,symbolPart];
        }
                
        childNodeOffset = self.value->export_off +   [self.machOFile.chunker readUleb128];
        saveOffset = [self.machOFile.chunker dataOffset];
        // go there
        //printf("VISITING OFFSET: %llx\n", childNodeOffset);
        [self.machOFile.chunker setDataOffset:childNodeOffset];
        [self walkExports:newSymbol];
        // rewind buffer position
        //printf("BACK TO OFFSET: %lx\n", (unsigned long)saveOffset);
        [self.machOFile.chunker setDataOffset:saveOffset];
        
    }
   
}

+(NSSet<NSString*>*)dontSerialize {
    /*NSSet *superSet = [super dontSerialize];
    NSMutableSet *newSet = [NSMutableSet setWithSet:superSet];
    [newSet addObject:@"_bindOpcodeDefs"];*/
    return [NSSet setWithObject:@"_bindOpcodeDefs"];
}

-(NSString*) description {
    return [[NSString alloc] initWithFormat:@"%@: %@\n",self.loadCommandType, self.exportedSymbols];
}

@end
