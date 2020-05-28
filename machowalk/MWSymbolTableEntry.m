//
//  MWSymbolTableEntry.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#include <mach-o/loader.h>
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSymbolTableEntry.h"

@implementation MWSymbolTableEntry
@synthesize value;
@synthesize real_n_type;
@synthesize name;
@synthesize external;
@synthesize ordinal;
@synthesize section;
@synthesize referenceType;
@synthesize type;
@synthesize alignment;
@synthesize n_type_n_type;

//MWDefinedNumber *ordinal;
//MWDefinedNumber *referenceType;
//MWDefinedNumber *type;

static MWDefinitions *referenceTypeDefs;
static MWDefinitions *ordinalDefs;
static MWDefinitions *typeDefs;

- (void)process {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct nlist_64)];
    
    self.rawStruct = @[
        MAP_STRUCT(nlist_64, n_type),
        MAP_STRUCT(nlist_64, n_sect),
        MAP_STRUCT(nlist_64, n_desc),
        MAP_STRUCT(nlist_64, n_value),
        MAP_STRUCT(nlist_64, n_un.n_strx)
    ];
    
    if ((self.value->n_type & N_STAB) > 0) {
        debug(@"TODO: handlee N_STAB\n", NULL);
    }
    
    if ((self.value->n_type & N_PEXT) > 0) {
        debug(@"TODO: handle N_PEXT\n", NULL);
    }
    
    if ((self.value->n_type & N_EXT) > 0) {
        // this symbol is offered externally to other modules
        self.external = true;
    } else {
        self.external = false;
    }
    
    self.real_n_type = self.value->n_type & N_TYPE;
    
    self.type = [typeDefs get:@(real_n_type)];
    
    // handle offsets into the string table
    if (self.value->n_un.n_strx != 0) {
        NSNumber *offset = [[NSNumber alloc] initWithUnsignedInteger:self.value->n_un.n_strx];
        self.name = [self.machOFile.stringTableByOffset objectForKey:offset];
    } else {
        self.name = @"No name";
    }
    
    // the conditions for a common symbol
    if (self.real_n_type == N_UNDF && self.external) {
        if (self.value->n_value != 0) {
            //common symbol size in n_desc
        }
        [self handleCommonSymbol];
    } else {
        self.referenceType = [referenceTypeDefs get:@(self.value->n_desc)];
    }
    
    // if MH_TWOLEVEL
    /*if ([self.machOFile.header value]->flags == MH_TWOLEVEL) {
        printf("TODO: Handle TWO LEVEL\n");
    }*/
    //if (self.external) {
        /* The ordinal recorded
        * references the libraries listed in the Mach-O's LC_LOAD_DYLIB,
        * LC_LOAD_WEAK_DYLIB, LC_REEXPORT_DYLIB, LC_LOAD_UPWARD_DYLIB, and
        * LC_LAZY_LOAD_DYLIB, etc. load commands in the order they appear in the
        * headers.   The library ordinals start from 1. */
        uint16_t ordinal = GET_LIBRARY_ORDINAL(self.value->n_desc);

    //}
    
    switch (self.real_n_type) {
        case N_UNDF:
            /* undefined */
            [self setOrdinal:[[NSNumber alloc] initWithUnsignedInt:ordinal]];
            break;
            
        case N_SECT: /* defined in section number n_sect */
            // section ordinals
            [self setSection: [[NSNumber alloc] initWithUnsignedInt:self.value->n_sect]];
            break;
        case N_PBUD: /* prebound undefined (defined in a dylib) */
            [self setOrdinal:[[NSNumber alloc] initWithUnsignedInt:ordinal]];
            break;
        //case N_INDR:
            
        default:
            if (self.value->n_sect != 0 || ordinal != 0) {
                debug(@"Error: unhandled case with n_sect: %d and ordinal: %d, %@\n", self.value->n_sect, ordinal, self.type, NULL);
            }
    }
}

- (void)handleCommonSymbol {
    // n_value is the size of the common symbol
    if (self.value->n_sect != NO_SECT) {
        debug(@"PROBLEM - n_sect shouldn't be set\n", NULL);
    }
    
    uint16_t alignment = GET_COMM_ALIGN(self.value->n_desc);
    self.alignment = [NSNumber numberWithUnsignedShort:alignment];
}

- (NSNumber*)n_type_n_type {
    //pure insanity... see nlist.h
    // this is purely for serialization
    
    return [NSNumber numberWithUnsignedChar:self.real_n_type];
}

- (NSString*)externalDescription {
    if (self.external) {
        return @"(external)";
    } else {
        return @"";
    }
}

- (NSString *)description {
    NSString *externalDesc = [self externalDescription];
    
    return [[NSString alloc] initWithFormat:@"external:%@ name:%@ refType:%@ type:%@ ordinal:%@ n_value:%#0llx", externalDesc, self.name, [self referenceType], [self type], [self ordinal], self.value->n_value];
}

+ (void)initialize {
    if (self != [MWSymbolTableEntry class]) {
        return;
    }
    
    referenceTypeDefs = [[MWDefinitions alloc] init:@"mach-o/nlist.h" mappings: @{
        MAP_DEFINE(REFERENCE_FLAG_UNDEFINED_NON_LAZY),
        MAP_DEFINE(REFERENCE_FLAG_UNDEFINED_LAZY),
        MAP_DEFINE(REFERENCE_FLAG_DEFINED),
        MAP_DEFINE(REFERENCE_FLAG_PRIVATE_DEFINED),
        MAP_DEFINE(REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY),
        MAP_DEFINE(REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY),
        MAP_DEFINE(REFERENCED_DYNAMICALLY)
    }];
    
    ordinalDefs = [[MWDefinitions alloc] init:@"mach-o/nlist.h" mappings: @{
        MAP_DEFINE(SELF_LIBRARY_ORDINAL),
        MAP_DEFINE(MAX_LIBRARY_ORDINAL),
        MAP_DEFINE(DYNAMIC_LOOKUP_ORDINAL),
        MAP_DEFINE(EXECUTABLE_ORDINAL)
    }];
    
    typeDefs = [[MWDefinitions alloc] init:@"mach-o/nlist.h" mappings: @{
        MAP_DEFINE(N_UNDF),
        MAP_DEFINE(N_ABS),
        MAP_DEFINE(N_SECT),
        MAP_DEFINE(N_PBUD),
        MAP_DEFINE(N_INDR)
    }];
}
@end
