//
//  MWSourceVersionCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSourceVersionCommand_h
#define MWSourceVersionCommand_h

#include "mach-o/loader.h"

#import "MWLoadCommand.h"
#import "util/MWDefinedNumber.h"

@interface MWSourceVersionCommand : MWLoadCommand
@property (nonatomic) NSString *version;
@property (nonatomic) NSArray<NSNumber*> *versionParts;
@property (nonatomic) struct source_version_command *value;
@end

#endif /* MWSourceVersionCommand_h */
