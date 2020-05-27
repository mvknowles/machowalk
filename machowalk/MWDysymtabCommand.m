//
//  MWDysymtabCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#include <inttypes.h>
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWDysymtabCommand.h"
#import "MWSymbolTableEntry.h"
#import "MWMachHeader64.h"
#import "MWKeyValue.h"

@implementation MWDysymtabCommand

- (void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct dysymtab_command)];
    
    if ((self.machOFile.header.value->flags & MH_BINDATLOAD) > 0) {
        debug(@"TODO: MH_BINDATLOAD found. Not handled (need to sort stuff");
    }
    debug(@"TODO: sort the symbols into each table type");
    // defined external symbols
    for (int i=0; i<self.value->nextdefsym;i++) {
        MWSymbolTableEntry *entry;
        int tableIndex;
        
        tableIndex = self.value->iextdefsym + i;
        entry = [self.machOFile.symbolTableEntries objectAtIndex:tableIndex];
        debug(@"External: %@", entry.name);
    }
    
    // undefined external symbols
    for (int i=0; i<self.value->nundefsym;i++) {
        MWSymbolTableEntry *entry;
        int tableIndex;
        
        tableIndex = self.value->iundefsym + i;
        entry = [self.machOFile.symbolTableEntries objectAtIndex:tableIndex];
        debug(@"Undefined: %@", entry.name);
    }

    self.rawStruct = @[
        MAP_STRUCT(dysymtab_command, cmd),
        MAP_STRUCT(dysymtab_command, cmdsize),
        MAP_STRUCT(dysymtab_command, ilocalsym),
        MAP_STRUCT(dysymtab_command, nlocalsym),
        MAP_STRUCT(dysymtab_command, iextdefsym),
        MAP_STRUCT(dysymtab_command, nextdefsym),
        //MAP_STRUCT_FORMAT(dysymtab_command, nextdefsym, @"%@: %x"),
        MAP_STRUCT(dysymtab_command, iundefsym),
        MAP_STRUCT(dysymtab_command, nundefsym),
        MAP_STRUCT(dysymtab_command, tocoff),
        MAP_STRUCT(dysymtab_command, ntoc),
        MAP_STRUCT(dysymtab_command, modtaboff),
        MAP_STRUCT(dysymtab_command, nmodtab),
        MAP_STRUCT(dysymtab_command, extrefsymoff),
        MAP_STRUCT(dysymtab_command, nextrefsyms),
        MAP_STRUCT(dysymtab_command, indirectsymoff),
        MAP_STRUCT(dysymtab_command, nindirectsyms),
        MAP_STRUCT(dysymtab_command, extreloff),
        MAP_STRUCT(dysymtab_command, nextrel),
        MAP_STRUCT(dysymtab_command, locreloff),
        MAP_STRUCT(dysymtab_command, nlocrel)
    ];
}
-(NSString*)description {
    return [NSString stringWithFormat:@"%@: %@", self.className, self.rawStruct];
}
@end
