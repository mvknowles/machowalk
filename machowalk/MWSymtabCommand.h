//
//  MWSymtabCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSymtabCommand_h
#define MWSymtabCommand_h

#import "MWLoadCommand.h"

@interface MWSymtabCommand : MWLoadCommand
@property (nonatomic) struct symtab_command *value;
@end

#endif /* MWSymtabCommand_h */
