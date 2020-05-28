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
#import "util/MWDefinedNumber.h"
#import "util/MWSerializerHints.h"

@interface MWExportedSymbol : MWMachElement <MWSerializerHints>
@property (retain, nonatomic) NSNumber *offset;
@property (retain, nonatomic) NSString *symbol;
@property (retain, nonatomic) MWDefinedNumber* kind;
@property (retain, nonatomic) NSArray<MWDefinedNumber*> *flags;
+(instancetype) createFromFlags:(uint8_t)flags symbol:(NSString*)symbol machOFile:(MWMachOFile*)machOFile;
+(NSSet<NSString*>*)dontSerialize;
@end

#endif /* MWExportedSymbol_h */
