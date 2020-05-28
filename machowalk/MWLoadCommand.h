//
//  MWLoadCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWLoadCommand_h
#define MWLoadCommand_h

#include "mach-o/loader.h"

#import "MWMachElement.h"
#import "util/MWDefinedNumber.h"

@interface MWLoadCommand : MWMachElement
@property (nonatomic) struct load_command *preamble;
@property (nonatomic) MWDefinedNumber *loadCommandType;
@property (nonatomic) NSUInteger saveDataOffset;
+(instancetype)createFromPreamble:(MWMachOFile*)machOFile;
-(void)subprocess;
-(instancetype)init:(struct load_command*)preamble machOFile:(MWMachOFile*)machOFile;
@end


#endif /* MWLoadCommand_h */
