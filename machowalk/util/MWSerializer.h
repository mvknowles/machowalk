//
//  MWSerializer.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSerializer_h
#define MWSerializer_h

#import "MWSerializerHints.h"

@interface MWDebugStackEntry : NSObject
@property (nonatomic) NSObject *target;
@property (nonatomic) NSString *caller;
@end

@interface MWPropertyInfo : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) BOOL isKVC;
@end

@interface MWSerializer : NSObject
@property (nonatomic) NSSet<NSString*> *excludedClasses;
@property (nonatomic) NSMutableArray<MWDebugStackEntry*> *debugStack;
@property (nonatomic) BOOL jsonMode;

-(NSMutableArray<MWPropertyInfo*>*)objectProperties:(NSObject*)target;
-(NSObject*)normalize:(NSObject*)rootObject;
-(NSObject*)normalizeObject:(NSObject*)target;
-(NSArray*)normalizeArray:(NSArray*)target;
-(NSDictionary*)normalizeDictionary:(NSDictionary*)target;
+(BOOL)isFoundation:(NSObject*)o;
-(void)stackDebug:(NSString*)format, ...;
-(MWDebugStackEntry*)debugStackPop;
-(void)debugStackPush:(NSObject*)target;
-(void)jsonify:(NSObject*)target;
@end

#endif /* MWSerializer_h */
