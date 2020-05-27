//
//  MWExportedSymbol.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWExportedSymbol_h
#define MWExportedSymbol_h

#import "MWMachElement.h"
#import "MWDefinedNumber.h"
#import "MWSerializerHints.h"

@interface MWExportedSymbol : MWMachElement <MWSerializerHints>
@property (nonatomic) NSNumber *offset;
@property (nonatomic) NSString *symbol;
@property (nonatomic) MWDefinedNumber* kind;
@property (nonatomic) NSArray<MWDefinedNumber*> *flags;
+(instancetype) createFromFlags:(uint8_t)flags symbol:(NSString*)symbol machOFile:(MWMachOFile*)machOFile;
+(NSSet<NSString*>*)dontSerialize;
@end

#endif /* MWExportedSymbol_h */
