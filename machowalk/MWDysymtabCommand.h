//
//  MWDysymtabCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWDysymtabCommand_h
#define MWDysymtabCommand_h

#include <mach-o/loader.h>

#import "MWLoadCommand.h"
#import "MWExportedSymbol.h"

@interface MWDysymtabCommand : MWLoadCommand
@property (nonatomic) struct dysymtab_command *value;

@end

#endif /* MWDysymtabCommand_h */
