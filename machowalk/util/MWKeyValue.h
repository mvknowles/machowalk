//
//  MWKeyValue.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWKeyValue_h
#define MWKeyValue_h

#import "MWSerializerHints.h"

#define QUOTE(x) #x
#define MAP_STRUCT(n,p) [[MWKeyValue alloc] init:@QUOTE(n.p) value:@(self.value->p)]
#define MAP_OTHER_STRUCT(n,p,t) [[MWKeyValue alloc] init:@QUOTE(n.p) value:@(t->p)]
#define MAP_STRUCT_FORMAT(n,p,f) [[MWKeyValue alloc] init:@QUOTE(n.p) value:@(self.value->p) withFormat:f]

@interface MWKeyValue : NSObject <MWSerializerHints>
@property (nonatomic) NSString *key;
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *formatString;
-(instancetype)init:(NSString*)key value:(NSNumber*)value;
-(instancetype)init:(NSString*)key value:(NSNumber*)value withFormat:(NSString*)format;
-(NSObject*)normalizerOverride;
@end

#endif /* MWKeyValue_h */
