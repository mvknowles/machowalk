//
//  MWMachHeader64.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWMachHeader64_h
#define MWMachHeader64_h

#include <mach-o/loader.h>

#import "MWLoadCommand.h"
#import "MWMachElement.h"
#import "util/MWDefinitions.h"
#import "util/MWDefinedNumber.h"


@interface MWMachHeader64 : MWMachElement

@property (nonatomic) MWDefinedNumber *magic;
@property (nonatomic) MWDefinedNumber *fileType;
@property (nonatomic) struct mach_header_64 *value;
@property (nonatomic) NSUInteger headerLength;

@end

#endif /* MWMachHeader64_h */
