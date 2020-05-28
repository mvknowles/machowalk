//
//  MWExportedSymbol.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#include <mach-o/loader.h>
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWExportedSymbol.h"
#import "util/MWDefinitions.h"


@interface MWExportedSymbolNormal : MWExportedSymbol
@property (retain, nonatomic) NSNumber *contentOffset;
@end

@implementation MWExportedSymbolNormal
@synthesize contentOffset;
-(void)process {
    uint64_t contentOffset;
    contentOffset = [self.machOFile.chunker readUleb128];
    [self setContentOffset: [NSNumber numberWithUnsignedLongLong:contentOffset]];
}
-(NSString*)description {
    return @"";
    return [NSString stringWithFormat:@"%@ %#llx", [super description], self.contentOffset.unsignedLongLongValue];
}
@end

@interface MWExportedSymbolReexport : MWExportedSymbol
@property (retain, nonatomic) NSNumber *libraryOrdinal;
@property (retain, nonatomic) NSString *reexportedSymbol;
@end

@implementation MWExportedSymbolReexport
@synthesize libraryOrdinal;
@synthesize reexportedSymbol;
-(void)process {
    uint64_t libraryOrdinal;
    NSString *reexportSymbol;
    
    libraryOrdinal = [self.machOFile.chunker readUleb128];
    [self setLibraryOrdinal:[NSNumber numberWithUnsignedLongLong:libraryOrdinal]];
    // If the string is zero length, then the symbol
    //    * is re-export from the specified dylib with the same name.
    // null-terminated UTF-8 byte sequence follows
    reexportSymbol = [self.machOFile.chunker readUTF8String];
    [self setReexportedSymbol:reexportSymbol];
    debug(@"TO TEST: EXPORT_SYMBOL_FLAGS_REEXPORT: %@", reexportSymbol, nil);
}
@end

@interface MWExportedSymbolStub : MWExportedSymbol
@property (retain, nonatomic) NSNumber *stubOffset;
@property (retain, nonatomic) NSNumber *stubResolverOffset;
@end

@implementation MWExportedSymbolStub
@synthesize stubOffset;
@synthesize stubResolverOffset;
-(void)process {
    uint64_t stubOffset;
    uint64_t stubResolverOffset;
    
    stubOffset = [self.machOFile.chunker readUleb128];
    stubResolverOffset = [self.machOFile.chunker readUleb128];
}
@end


@implementation MWExportedSymbol
@synthesize offset;
@synthesize symbol;
@synthesize kind;
@synthesize flags;

static MWDefinitions *kindDefs;
static MWDefinitions *flagDefs;

+ (void)initialize {
    if (self != [MWExportedSymbol class]) {
        return;
    }

    kindDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_KIND_REGULAR),
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL),
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE)
    }];
    
    flagDefs = [[MWDefinitions alloc] init:@"mach-o/loader.h" mappings:@{
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION),
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_REEXPORT),
        MAP_DEFINE(EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER)
    }];
}

+(instancetype) createFromFlags:(uint8_t)flags symbol:(NSString*)symbol machOFile:(MWMachOFile*)machOFile {

    MWExportedSymbol *n;
    
    uint8_t exportKind = flags & EXPORT_SYMBOL_FLAGS_KIND_MASK;
    uint8_t exportFlags = flags & (0xFF | EXPORT_SYMBOL_FLAGS_KIND_MASK);
    
    switch (exportFlags) {
        case 0x00: // REGULAR
        case EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION:
            n = [[MWExportedSymbolNormal alloc] init:machOFile];
            break;
        case EXPORT_SYMBOL_FLAGS_REEXPORT:
            n = [[MWExportedSymbolReexport alloc] init:machOFile];
            break;
        case EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER:
            debug(@"TO TEST: EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER\n", NULL);
            if (exportKind == EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL || exportKind == EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE) {
                // this is invalid. dyld will not allow this
                debug(@"ERROR: NOT STUB RESOLVER NOT ALLOWED FOR KIND", NULL);
            }
            n = [[MWExportedSymbolStub alloc] init:machOFile];
            break;
        default:
            debug(@"ERROR: unhandled export symbol flags: %d", exportFlags, NULL);
            n = [[MWExportedSymbol alloc] init];
    }
    
    [n setSymbol:symbol];
    [n setKind:[kindDefs get:@(exportKind)]];
    [n setFlags:[flagDefs getFlags:@(exportFlags)]];
    
    [n process];

    return n;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ %@", self.kind, self.flags, self.symbol];
}

+(NSSet<NSString*>*)dontSerialize {
    return [NSSet setWithObject:@"origStruct"];
}

@end
