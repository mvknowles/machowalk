//
//  MWSerializer.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSerializer_h
#define MWSerializer_h

#import <objc/runtime.h>
#import "MWSerializerHints.h"

@interface MWDebugStackEntry : NSObject
@property (retain, nonatomic) NSObject *target;
@property (retain, nonatomic) NSString *caller;
@property (retain, nonatomic) NSString *details;
-(NSUInteger)hash;
-(BOOL)isEqual:(id)object;
@end

@interface MWPropertyInfo : NSObject
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *type;
@property (nonatomic) BOOL isKVC;
@end

@interface MWSerializer : NSObject
@property (retain, nonatomic) NSSet<NSString*> *excludedClasses;
@property (retain, nonatomic) NSMutableOrderedSet<MWDebugStackEntry*> *objectStack;
@property (nonatomic) BOOL jsonMode;

-(NSObject*)normalize:(NSObject*)rootObject;
-(NSObject*)normalizeObject:(NSObject*)target;
-(NSArray*)normalizeArray:(NSArray*)target;
-(NSDictionary*)normalizeDictionary:(NSDictionary*)target;
-(MWDebugStackEntry*)stackPop;
-(void)stackPush:(NSObject*)target;
-(void)stackPush:(NSObject*)target withDetails:(NSString*)details;
-(void)jsonify:(NSObject*)target;

+(BOOL)isFoundation:(NSObject*)o;
+(NSMutableArray<MWPropertyInfo*>*)newObjectPropertiesForObject:(const NSObject*)target;
+(void)addPropertiesForClass:(Class)target_class results:(const NSMutableArray<MWPropertyInfo*>*)results;
+(MWPropertyInfo*)newPropertyInfoForProperty:(const objc_property_t)property;

-(void)stackDebug:(NSString*)format, ... NS_REQUIRES_NIL_TERMINATION;
@end

#endif /* MWSerializer_h */
