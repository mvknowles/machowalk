//
//  MWSymtabCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSymtabCommand.h"
#import "MWSymbolTableEntry.h"

@implementation MWSymtabCommand
/*-(instancetype) init:(struct load_command*)preamble {
    self = [super init:preamble];
} */

-(void)subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct symtab_command) increment:false];
    
    self.machOFile.stringTable = [[NSMutableArray alloc] init];
    self.machOFile.stringTableByOffset = [[NSMutableDictionary alloc] init];
    
    // String table processing
    NSUInteger lastNull = 0;
    NSUInteger offset = self.value->stroff;
    char c;
    for (NSUInteger i = 0; i < self.value->strsize; i++) {
        c = [self.machOFile.chunker byteAt:offset + i];
        //char c = ((const char*)data.bytes)[offset + i];

        if (c == '\0') {
            NSRange newEntryRange = NSMakeRange(offset + lastNull, i - lastNull);
            // skip 0-length strings (padding)
            if (newEntryRange.length == 0) {
                //debug(@"padding");
                lastNull = i + 1;
                continue;
            }
            //debug(@"%lu %lu", (unsigned long)newEntryRange.location, (unsigned long)newEntryRange.length);
            NSData *newEntryData = [[self.machOFile.chunker data] subdataWithRange:newEntryRange];
            
            NSString *newEntry = [[NSString alloc] initWithData:newEntryData encoding:NSUTF8StringEncoding];
            //debug(@"%@", newEntry);
            
            // key offset will be the location - 4 (to accomodate the inital 4 bytes)
            NSNumber *keyOffset = [[NSNumber alloc] initWithUnsignedInteger:newEntryRange.location - offset];
            [self.machOFile.stringTable addObject: newEntry];
            [self.machOFile.stringTableByOffset setObject:newEntry forKey:keyOffset];
            
            lastNull = i + 1;
        }
    }
    
    // Symbol table processing
    //struct nlist *entry;
    [self.machOFile.chunker setDataOffset:self.value->symoff];
    self.machOFile.symbolTableEntries = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.value->nsyms; i++) {
        MWSymbolTableEntry *newSymbolTableEntry = [[MWSymbolTableEntry alloc] init:self.machOFile];
        [newSymbolTableEntry process];
        [self.machOFile.symbolTableEntries addObject:newSymbolTableEntry];
        debug(@"%@", newSymbolTableEntry);
        // entry->n_un.n_strx is the *offset* into the string table, not an index
        //printf("%x\n", entry->n_un.n_strx);
    }

    self.rawStruct = @[
        MAP_STRUCT(symtab_command, cmd),
        MAP_STRUCT(symtab_command, cmdsize),
        MAP_STRUCT(symtab_command, symoff),
        MAP_STRUCT(symtab_command, nsyms),
        MAP_STRUCT(symtab_command, stroff),
        MAP_STRUCT(symtab_command, strsize)
    ];
}
-(NSString*) description {
    return @"Symtab command"; //[[NSString alloc] initWithFormat:@"Dylib name: %@\n",self.name];
}
@end
