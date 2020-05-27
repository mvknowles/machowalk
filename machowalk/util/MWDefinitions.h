//
//  MWDefinitions.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWDefinitions_h
#define MWDefinitions_h

#import "MWDefinedNumber.h"

#define MAP_DEFINE(symbol) @symbol : @#symbol

@interface MWDefinitions : NSObject
@property (nonatomic) NSString *path;
@property (nonatomic) NSDictionary<NSNumber*,NSString*> *mappings;
+ (instancetype)from:(NSString*)path with:(NSDictionary<NSNumber*,NSString*>*)mappings;
- (instancetype)init:(NSString*)path mappings:(NSDictionary<NSNumber*,NSString*>*)mappings;
- (MWDefinedNumber*)get:(NSNumber*)number;
- (NSMutableArray<MWDefinedNumber*>*)getFlags:(NSNumber*)flags;
@end

#endif /* MWDefinitions_h */
