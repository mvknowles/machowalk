//
//  MWMachElement.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWMachElement_h
#define MWMachElement_h

#import "MWChunker.h"
#import "MWMachOFile.h"
#import "MWKeyValue.h"
#import "MWSerializerHints.h"

@interface MWMachElement : NSObject <MWSerializerHints>

@property (nonatomic) MWMachOFile *machOFile;
@property (nonatomic) NSUInteger elementOffset;
@property (nonatomic) NSArray<MWKeyValue*>* rawStruct;
@property (nonatomic) NSDictionary<NSString*,NSObject*> *origStruct;

- (instancetype)init:(MWMachOFile*)machOFile;
- (void)process;

@end

#endif /* MWMachElement_h */
