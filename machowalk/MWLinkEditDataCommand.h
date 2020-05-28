//
//  MWLinkDataEditCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWLinkEditDataCommand_h
#define MWLinkEditDataCommand_h


#include "mach-o/loader.h"

#import "MWLoadCommand.h"
#import "util/MWDefinedNumber.h"

@interface MWLinkEditDataCommand : MWLoadCommand
@property (nonatomic) struct linkedit_data_command *value;
@end


#endif /* MWLinkEditDataCommand_h */
