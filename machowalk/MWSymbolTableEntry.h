//
//  MWSymbolTableEntry.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSymbolTableEntry_h
#define MWSymbolTableEntry_h

#include <mach-o/nlist.h>

#import "MWMachElement.h"
#import "MWDefinitions.h"
#import "MWDefinedNumber.h"

@interface MWSymbolTableEntry : MWMachElement
@property (nonatomic) struct nlist_64 *value;
@property (nonatomic) NSString *name;
@property (nonatomic) uint8_t real_n_type;
@property (nonatomic) BOOL external;
@property (nonatomic) NSNumber *ordinal;
@property (nonatomic) NSNumber *section;
@property (nonatomic) NSNumber *alignment;
@property (nonatomic) MWDefinedNumber *referenceType;
@property (nonatomic) MWDefinedNumber *type;
@property (nonatomic) NSNumber *n_type_n_type;
//@property (nonatomic, class, readonly) MWDefinitions *referenceTypeDefs;
//@property (nonatomic, class, readonly) MWDefinitions *ordinalDefs;
//@property (nonatomic, class, readonly) MWDefinitions *typeDefs;
@end

#endif /* MWSymbolTableEntry_h */
