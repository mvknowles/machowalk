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
#import "MWDefinitions.h"
#import "MWSerializerHints.h"

@interface MWDyldInfoCommand : MWLoadCommand <MWSerializerHints>
@property (nonatomic) struct dyld_info_command *value;
@property (nonatomic) MWDefinitions *bindOpcodeDefs;
@property (nonatomic) NSMutableArray<MWExportedSymbol*> *exportedSymbols;
+(NSSet<NSString*>*)dontSerialize;
@end

#endif /* MWDyldInfoCommand_h */
