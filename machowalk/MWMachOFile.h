//
//  MWMachOFile.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWMachOFile_h
#define MWMachOFile_h

#import "util/MWChunker.h"
#import "util/MWSerializerHints.h"

@class MWMachHeader64;
@class MWSymbolTableEntry;
@class MWLoadCommand;

@interface MWMachOFile : NSObject <MWSerializerHints>

@property (nonatomic) NSMutableArray<NSString *> *stringTable;
@property (nonatomic) NSMutableDictionary<NSNumber*, NSString*> *stringTableByOffset;
@property (nonatomic) NSMutableArray<MWSymbolTableEntry *> *symbolTableEntries;
@property (nonatomic) MWChunker *chunker;
@property (nonatomic) MWMachHeader64 *header;
@property (nonatomic) NSMutableArray<MWLoadCommand*> *loadCommands;
@property (nonatomic) NSString *path;

-(instancetype)init:(NSString*)path;
-(void)process;
+(NSSet<NSString*>*)dontSerialize;

@end

#endif /* MWMachOFile_h */
