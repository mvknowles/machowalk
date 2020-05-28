//
//  MWBuildVersionCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWBuildVersionCommand_h
#define MWBuildVersionCommand_h

#include "mach-o/loader.h"

#import "MWLoadCommand.h"
#import "util/MWDefinedNumber.h"

@interface MWBuildTool : NSObject
@property (nonatomic) NSObject *name;
@property (nonatomic) NSNumber *version;
@end

@interface MWBuildVersionCommand : MWLoadCommand
@property (nonatomic) MWDefinedNumber* platformDef;
@property (nonatomic) NSMutableArray<MWBuildTool*> *buildTools;
@property (nonatomic) struct build_version_command *value;
@end

#endif /* MWBuildVersionCommand_h */
