//
//  MWDefinedNumber.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWDefinedNumber_h
#define MWDefinedNumber_h

#import "MWSerializerHints.h"

@interface MWDefinedNumber : NSObject <MWSerializerHints>
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *headerFile;
- (instancetype)init:(NSNumber*)value name:(NSString*)name headerFile:(NSString*)headerFile;
@end

#endif /* MWDefinedNumber_h */
