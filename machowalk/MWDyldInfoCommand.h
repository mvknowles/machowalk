//
//  MWDyldInfoCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWDyldInfoCommand_h
#define MWDyldInfoCommand_h

#include <mach-o/loader.h>

#import "MWLoadCommand.h"
#import "MWExportedSymbol.h"
#import "util/MWDefinitions.h"
#import "util/MWSerializerHints.h"

@interface MWDyldInfoCommand : MWLoadCommand <MWSerializerHints>
@property (nonatomic) struct dyld_info_command *value;
@property (retain, nonatomic) MWDefinitions *bindOpcodeDefs;
@property (retain, nonatomic) NSMutableArray<MWExportedSymbol*> *exportedSymbols;
+(NSSet<NSString*>*)dontSerialize;
@end

#endif /* MWDyldInfoCommand_h */
