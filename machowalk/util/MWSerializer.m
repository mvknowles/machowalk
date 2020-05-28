//
//  MWSerializer.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles.
//

#include "dlfcn.h"
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSerializer.h"

@implementation MWDebugStackEntry
@synthesize target;
@synthesize caller;

- (NSUInteger)hash {
    // isEqual will be called to check even if the hashes collide
    return self.target.hash ^ self.caller.hash;
}
 
-(BOOL)isEqual:(id)other {
    // nice and quick
    if (other == self) {
        return YES;
    }
    
    if ([other isKindOfClass:[MWDebugStackEntry class]] == false) {
        return NO;
    }

    MWDebugStackEntry *dse = (MWDebugStackEntry*)other;
    
    return [self.target isEqual:dse.target] && [self.caller isEqualToString:dse.caller] && ((self.details == nil && dse.details == nil) || [self.details isEqualToString:dse.details]);
}
    


-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %lu", self.caller, self.target, self.details, (unsigned long)self.target.hash];
}

@end

@implementation MWPropertyInfo
@synthesize name;
@synthesize type;
@synthesize isKVC;
@end

@interface MWStdOutputStream : NSOutputStream
@end

@implementation MWStdOutputStream

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len {
    return write(1, buffer, len);
}

- (NSStreamStatus)streamStatus {
    return NSStreamStatusOpen;
}

- (BOOL)hasSpaceAvailable {
    return true;
}

@end

@implementation MWSerializer

@synthesize objectStack;
@synthesize jsonMode;

static NSSet<NSString*> *foundationClasses;

+(void)initialize {
    if (self != [MWSerializer class]) {
        return;
    }
    
    foundationClasses = [NSSet setWithObjects:@"NSArray", @"NSDictionary", @"NSString", @"NSNumber", @"NSNull", nil];
}

-(instancetype)init {
    self.objectStack = [NSMutableOrderedSet new];
    self.jsonMode = true;
    return self;
}

-(void)jsonify:(NSObject*)target {
    MWStdOutputStream *output = [MWStdOutputStream new];
    NSObject *normalizedObject;
    
    normalizedObject = [self normalize:target];
    
    NSError *error = nil;
    [NSJSONSerialization writeJSONObject:normalizedObject toStream:output options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
}


-(void)stackDebug:(NSString*)format, ... {    
    /*NSMutableString *prefix = [[NSMutableString alloc] init];
    for (MWDebugStackEntry *entry in self.objectStack) {
        [prefix appendFormat:@"%@ ", entry.target]; //, entry.caller];
    }
    */
  
    va_list vargs;
    va_start(vargs, format);
    //NSString *newFormat = [[NSString alloc] initWithFormat:format arguments:vargs];
    
    //const char *c = newFormat.UTF8String;
    
    //printf("%s\n", c);
    
    
    //NSLogv(format, vargs);
    debug(format, vargs, NULL);
    va_end(vargs);
}

-(void)stackPush:(NSObject*)target {
    [self stackPushInternal:target withDetails:nil];
}

-(void)stackPush:(NSObject*)target withDetails:(NSString*)details {
    [self stackPushInternal:target withDetails:details];
}

-(void)stackPushInternal:(NSObject*)target withDetails:(NSString*)details {
    NSString *caller;
    NSError *error;
    
    if ([objectStack count] > 10) {
        NSLog(@"Object stack too large");
        exit(3);
    }
    
    caller = [[NSThread callStackSymbols] objectAtIndex:2];
    // this is annoyingly dumb. Why can't we just get the underlying data in a non-string (in a way that is portable)
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.* (.*)\\]" options:0 error:&error];
    NSRange range = NSMakeRange(0, caller.length);
    NSArray *matches = [regex matchesInString:caller options:0 range:range];
    if (matches.count >= 1) {
        NSRange group1 = [matches[0] rangeAtIndex:1];
        caller = [caller substringWithRange:group1];
    }
    
    MWDebugStackEntry *entry = [[MWDebugStackEntry alloc] init];
    [entry setCaller:caller];
    [entry setTarget:[target className]];
    [entry setDetails:details];
    
    if ([self.objectStack containsObject:entry]) {
        NSMutableString *callStackLines = [NSMutableString stringWithString:[[self.objectStack array] componentsJoinedByString:@"\n"]];
        // put the last "attemted" call on the stack
        [callStackLines appendString:@"\n"];
        [callStackLines appendString:[entry description]];
        
        NSString *reason = [NSString stringWithFormat:@"Serializer will loop with object %@\nCallstack:\n%@", [target className], callStackLines];
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:@{@"objectStack":self.objectStack}]);
    }
    
    [self.objectStack addObject:entry];
}

-(MWDebugStackEntry*)stackPop {
    MWDebugStackEntry *pop = [self.objectStack lastObject];
    [self.objectStack removeObjectAtIndex:[self.objectStack count] - 1 ];
    return pop;
}

-(NSObject*)normalize:(NSObject*)target {
    //MK [self stackPush:target];
    
    NSString *targetType = [[[target class] classForArchiver] className];
    [self stackDebug:@"Target type: %@, %@", targetType, [target class], nil];
    NSObject *result;
        
    if ([[target class] isSubclassOfClass:[NSArray class]]) {
        [self stackDebug:@"process array", nil];
        result = [self normalizeArray:(NSArray*)target];
        //MK[self stackPop];
        return result;
    }
    
    //if ([targetType isEqual:@"NSMutableDictionary"] || [targetType isEqual:@"NSDictionary"]) {
    if ([[target class] isSubclassOfClass:[NSDictionary class]]) {
        result = [self normalizeDictionary:(NSDictionary*)target];
        //mk [self stackPop];
        return result;
    }
    
    if ([[target class] isSubclassOfClass:[NSNumber class]] || [[target class] isSubclassOfClass:[NSString class]]) {
        [self stackDebug:@"process string or number", nil];
        result = target;
        //mk [self stackPop];
        return result;
    }
        
    [self stackDebug:@"process as object", nil];
    
    result = [self normalizeObject:target];
    //[self stackPop];
    return result;
}

-(NSObject*)normalizeObject:(NSObject*)target {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray<MWPropertyInfo*> *propertyInfos;
    NSMutableSet<NSString*>*dontSerializeSet;
    
    [self stackPush:target];
    dontSerializeSet = [NSMutableSet new];;
    
    if ([target conformsToProtocol:@protocol(MWSerializerHints)]) {
        [self stackDebug:@"%@ responds to hints", [target class], nil];
        
        if ([target respondsToSelector:@selector(normalizerOverride)]) {
            [self stackDebug:@"%@ has normalizerOverload", [target class], nil];
            result = [target performSelector:@selector(normalizerOverride)];
            [self stackPop];
            return result;
        }
        
        // determine whether the target or any of it's superclasses implements
        // the dontSerialize selector. We need to do this to the superclasses
        // because each level may have it's own properties that shouldn't
        // be serialized. If we just check the target, we don't get the full
        // set
        Class cls = [target class];
        while (cls != [NSObject class]) {
            if ([cls respondsToSelector:@selector(dontSerialize)]) {
                [dontSerializeSet unionSet:[cls performSelector:@selector(dontSerialize)]];
            }
            cls = [cls superclass];
        }
        [self stackDebug:@"dont list: %@", dontSerializeSet, nil];
    }
    
    propertyInfos = [MWSerializer newObjectPropertiesForObject:target];
    for (MWPropertyInfo *info in propertyInfos) {
        NSObject *normalized;
        NSObject *propertyValue;
        [self stackDebug:@"PROP ANALYSE: %@",info.name, nil];
        
        if ([dontSerializeSet containsObject:info.name]) {
            [self stackDebug:@"PROP: no serialize: %@", info.name, nil];
            continue;
        }

        if (info.isKVC == false) {
            [self stackDebug:@"PROP: Skip (not KVC) %@.%@", [target class], info.name, nil];
            continue;
        }
        
        propertyValue = [target valueForKey:info.name];
        /*if (propertyValue == target) {
            [self debug:@"PROP: preventing loop"];
            continue;
        }*/
        
        if (propertyValue == nil) {
            [self stackDebug:@"PROP: property nil", nil];
            normalized = [[NSNull alloc] init];
        } else {
            [self stackDebug:@"PROP: property needs normalizing further", nil];
            [self stackPush:target withDetails:info.name];
            normalized = [self normalize:propertyValue];
            [self stackPop];
        }
        // nil is returned by normalize if object should be skipped
        if (normalized != nil) {
            [result setObject:normalized forKey:info.name];
        }
    }
    
    [self stackPop];
    return result;
}

+(BOOL)isFoundation:(NSObject*)o {
    NSString *classType;
    
    classType = [[o classForArchiver] className];
    return [foundationClasses containsObject:classType];
}

-(NSArray*)normalizeArray:(NSArray*)target {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //mk[self stackPush:target];
    
    for (NSObject *o in target) {
        if ([result count] == 0) {
            if ([MWSerializer isFoundation:o]) {
                // nothing needs t be done to array
                //mk[self stackPop];
                return target;
            }
        }
        
        //normalize the data
        [result addObject:[self normalize:o]];
    }
    //mk[self stackPop];
    return result;
}

-(NSDictionary*)normalizeDictionary:(NSDictionary*)target {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //[self stackPush:target];
    
    for (NSObject *k in [target allKeys]) {
        NSObject *newKey = k;
        NSObject *v = [target objectForKey:k];
        
        if ([result count] == 0) {
            if ([MWSerializer isFoundation:k] && [MWSerializer isFoundation:v]) {
                if (self.jsonMode == false || [k isKindOfClass:[NSString class]]) {
                    // nothing needs t be done to array
                    //[self stackPop];
                    return target;
                }
            }
        }
        
        if ([MWSerializer isFoundation:k] == false) {
            newKey = [self normalize:k];
        }
        
        if ([MWSerializer isFoundation:v] == false) {
            v = [self normalize:v];
        }

        // the json serializer won't accept non-string as keys
        if (self.jsonMode && [k isKindOfClass:[NSString class]] == false) {
            newKey = [newKey description];
        }
        
        //normalize the data
        [result setObject:v forKey:(NSObject<NSCopying>*)newKey];
    }
    
    //[self stackPop];
    return result;
}


+(NSMutableArray<MWPropertyInfo*>*)newObjectPropertiesForObject:(const NSObject*)target {

    //NSMutableDictionary<NSString*,NSString*> *result = [[NSMutableDictionary alloc] init];
    NSMutableArray<MWPropertyInfo*> *results = [[NSMutableArray alloc] init];
    
    int i=0;
    Class cls = [target class];
    while (cls != [NSObject class]) {
        //NSLog(@"doing class: %@, i=%d", cls, i);
        [MWSerializer addPropertiesForClass:cls results:results];
        cls = [cls superclass];
        i++;
    }
    
    return results;
}

+(void)addPropertiesForClass:(Class)target_class results:(const NSMutableArray<MWPropertyInfo*>*)results {
    
    unsigned int propertyCount;
    objc_property_t *properties;
    properties = class_copyPropertyList(target_class, &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        MWPropertyInfo *propertyInfo;
        
        propertyInfo = [MWSerializer newPropertyInfoForProperty:properties[i]];
        
        if (propertyInfo != nil) {
            //NSLog(@"%@", propertyInfo.name);
            [results addObject:propertyInfo];
        }
    }
    
    free(properties);
}

+(MWPropertyInfo*)newPropertyInfoForProperty:(const objc_property_t)property {
    unsigned int attrCount;
    
    objc_property_attribute_t *propAttrs = property_copyAttributeList(property, &attrCount);

    MWPropertyInfo *propertyInfo = [[MWPropertyInfo alloc] init];
    propertyInfo.isKVC = true;
    
    for (int j=0; j < attrCount; j++) {
        objc_property_attribute_t attr = propAttrs[j];
        
        if (strlen(attr.name) <= 0) {
            continue;
        }
        switch (attr.name[0]) {
            case 'T':
                if (strlen(attr.value) > 0 && attr.value[0] == '^') {
                    propertyInfo.isKVC = false;
                }
                propertyInfo.type = [[NSString stringWithUTF8String:attr.value] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
                break;
            case 'V':
                // method I think
                propertyInfo.name = [NSString stringWithUTF8String:attr.value];
                break;
            case '&':
                // not sure
                //propertyInfo.isKVC = true;
                break;
            //default:
            //    printf("%s\n", attr->name);
        }
    }
    
    free(propAttrs);
    return propertyInfo;
}

@end
