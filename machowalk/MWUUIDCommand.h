//
//  MWUUIDCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWUUIDCommand_h
#define MWUUIDCommand_h

#include "mach-o/loader.h"

#import "MWLoadCommand.h"
#import "MWSerializerHints.h"

@interface MWUUIDCommand : MWLoadCommand // <MWSerializerHints>
@property (nonatomic) struct uuid_command *value;
@property (nonatomic) NSUUID *uuid;
@end

#endif /* MWUUIDCommand_h */
