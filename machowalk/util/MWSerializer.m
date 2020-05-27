//
//  MWSerializer.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles.
//

#include "dlfcn.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWSerializer.h"

@implementation MWDebugStackEntry
@synthesize target;
@synthesize caller;
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

@synthesize debugStack;
@synthesize jsonMode;

static NSSet<NSString*> *foundationClasses;

+(void)initialize {
    if (self != [MWSerializer class]) {
        return;
    }
    
    foundationClasses = [NSSet setWithObjects:@"NSArray", @"NSDictionary", @"NSString", @"NSNumber", @"NSNull", nil];
}

-(instancetype)init {
    self.debugStack = [[NSMutableArray alloc] init];
    self.jsonMode = true;
    return self;
}

-(void)jsonify:(NSObject*)target {
    MWStdOutputStream *output = [MWStdOutputStream new];
    NSError *error;
    NSObject *normalizedObject;
    
    normalizedObject = [self normalize:target];
    
    [NSJSONSerialization writeJSONObject:normalizedObject toStream:output options:NSJSONWritingPrettyPrinted error:&error];
            
    if (error != nil) {
        NSLog(@"%@", error.debugDescription);
    }
}


-(void)stackDebug:(NSString*)format, ... {
    NSMutableString *prefix = [[NSMutableString alloc] init];
    for (MWDebugStackEntry *entry in self.debugStack) {
        //NSLog(@"DEBUG: %@",entry);
        [prefix appendFormat:@"%@(%@).", entry.target, entry.caller];
    }
    
    NSString *newFormat = [NSString stringWithFormat:@"%@ %@", prefix, format];

    va_list vargs;
    va_start(vargs, format);
    debug(newFormat, vargs);
    va_end(vargs);
}

-(void)debugStackPush:(NSObject*)target {
    NSString *caller = [[NSThread callStackSymbols] objectAtIndex:1];
    NSError *error;
    
    // this is annoyingly dumb
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
    
    [self.debugStack addObject:entry];
}

-(MWDebugStackEntry*)debugStackPop {
    MWDebugStackEntry *pop = [self.debugStack lastObject];
    [self.debugStack removeLastObject];
    return pop;
}

-(NSObject*)normalize:(NSObject*)target {
    [self debugStackPush:target];
    
    NSString *targetType = [[[target class] classForArchiver] className];
    [self stackDebug:@"Taget type: %@, %@", targetType, [target class]];
    NSObject *result;
        
    if ([[target class] isSubclassOfClass:[NSArray class]]) {
        [self stackDebug:@"process array"];
        result = [self normalizeArray:(NSArray*)target];
        [self debugStackPop];
        return result;
    }
    
    //if ([targetType isEqual:@"NSMutableDictionary"] || [targetType isEqual:@"NSDictionary"]) {
    if ([[target class] isSubclassOfClass:[NSDictionary class]]) {
        result = [self normalizeDictionary:(NSDictionary*)target];
        [self debugStackPop];
        return result;
    }
    
    if ([[target class] isSubclassOfClass:[NSNumber class]] || [[target class] isSubclassOfClass:[NSString class]]) {
        [self stackDebug:@"process string or number"];
        result = target;
        [self debugStackPop];
        return result;
    }
        
    [self stackDebug:@"process as object"];
    
    // we pop the stack first because we're just doing ourselves again
    result = [self normalizeObject:target];
    [self debugStackPop];
    return result;
}

-(NSObject*)normalizeObject:(NSObject*)target {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray<MWPropertyInfo*> *propertyInfos;
    NSMutableSet<NSString*>*dontSerializeSet;
    
    [self debugStackPush:target];
    
    if ([target conformsToProtocol:@protocol(MWSerializerHints)]) {
        [self stackDebug:@"%@ responds to hints", [target class]];
        
        if ([target respondsToSelector:@selector(normalizerOverride)]) {
            [self stackDebug:@"%@ has normalizerOverload", [target class]];
            result = [target performSelector:@selector(normalizerOverride)];
            [self debugStackPop];
            return result;
        }
        
        // determine whether the target or any of it's superclasses implements
        // the dontSerialize selector. We need to do this to the superclasses
        // because each level may have it's own properties that shouldn't
        // be serialized. If we just check the target, we don't get the full
        // set
        Class cls = [target class];
        dontSerializeSet = [NSMutableSet new];
        while (cls != [NSObject class]) {
            if ([cls respondsToSelector:@selector(dontSerialize)]) {
                [dontSerializeSet unionSet:[cls performSelector:@selector(dontSerialize)]];
            }
            cls = [cls superclass];
        }
        [self stackDebug:@"dont list: %@", dontSerializeSet];
    }
    
    propertyInfos = [self objectProperties:target];
    for (MWPropertyInfo *info in propertyInfos) {
        NSObject *normalized;
        NSObject *propertyValue;
        [self stackDebug:@"PROP ANALYSE: %@",info.name];
        
        if ([dontSerializeSet containsObject:info.name]) {
            [self stackDebug:@"PROP: no serialize: %@", info.name];
            continue;
        }

        if (info.isKVC == false) {
            [self stackDebug:@"PROP: Skip %@.%@", [target class], info.name];
            continue;
        }
        
        propertyValue = [target valueForKey:info.name];
        /*if (propertyValue == target) {
            [self debug:@"PROP: preventing loop"];
            continue;
        }*/
        
        if (propertyValue == nil) {
            [self stackDebug:@"PROP: property nil"];
            normalized = [[NSNull alloc] init];
        } else {
            [self stackDebug:@"PROP: property needs normalizing further"];
            normalized = [self normalize:propertyValue];
            //normalized = [[NSNull alloc] init];
        }
        // nil is returned by normalize if object should be skipped
        if (normalized != nil) {
            [result setObject:normalized forKey:info.name];
        }
    }
    
    /*for (NSString *propertyName in propertyInfo) {
        NSObject *normalized;
        NSLog(@"Processing %@",propertyName);
        
        normalized = [self normalize:[target valueForKey:propertyName]];
        [result setObject:normalized forKey:propertyName];
    }*/
    
    [self debugStackPop];
    return result;
}

+(BOOL)isFoundation:(NSObject*)o {
    NSString *classType;
    
    classType = [[o classForArchiver] className];
    return [foundationClasses containsObject:classType];
}

-(NSArray*)normalizeArray:(NSArray*)target {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [self debugStackPush:target];
    
    for (NSObject *o in target) {
        if ([result count] == 0) {
            if ([MWSerializer isFoundation:o]) {
                // nothing needs t be done to array
                [self debugStackPop];
                return target;
            }
        }
        
        //normalize the data
        [result addObject:[self normalize:o]];
    }
    [self debugStackPop];
    return result;
}

-(NSDictionary*)normalizeDictionary:(NSDictionary*)target {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [self debugStackPush:target];
    
    for (NSObject *k in [target allKeys]) {
        NSObject *newKey = k;
        NSObject *v = [target objectForKey:k];
        
        if ([result count] == 0) {
            if ([MWSerializer isFoundation:k] && [MWSerializer isFoundation:v]) {
                if (self.jsonMode == false || [k isKindOfClass:[NSString class]]) {
                    // nothing needs t be done to array
                    [self debugStackPop];
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
    
    [self debugStackPop];
    return result;
}


-(NSMutableArray<MWPropertyInfo*>*)objectProperties:(NSObject*)target {

    //NSMutableDictionary<NSString*,NSString*> *result = [[NSMutableDictionary alloc] init];
    NSMutableArray<MWPropertyInfo*> *results = [[NSMutableArray alloc] init];
    
    int i=0;
    Class cls = [target class];
    while (cls != [NSObject class]) {
        //NSLog(@"doing class: %@, i=%d", cls, i);
        [self addPropertiesForClass:cls results:&results];
        cls = [cls superclass];
        i++;
    }
    
    return results;
}

-(void)addPropertiesForClass:(Class)target_class results:(NSMutableArray<MWPropertyInfo*>**)results {
    
    unsigned int propertyCount;
    objc_property_t *properties;
    
    properties = class_copyPropertyList(target_class, &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        MWPropertyInfo *propertyInfo;
        
        propertyInfo = [self propertyInfoForProperty:&properties[i]];
        
        if (propertyInfo != nil) {
            //NSLog(@"%@", propertyInfo.name);
            [*results addObject:propertyInfo];
        }
    }
    
    free(properties);
}

-(MWPropertyInfo*)propertyInfoForProperty:(objc_property_t*)property {
    unsigned int attrCount;
    
    objc_property_attribute_t *propAttrs = property_copyAttributeList(*property, &attrCount);

    MWPropertyInfo *propertyInfo = [[MWPropertyInfo alloc] init];
    for (int j=0; j < attrCount; j++) {
        objc_property_attribute_t *attr = &propAttrs[j];
        
        if (strlen(attr->name) <= 0) {
            continue;
        }
        switch (attr->name[0]) {
            case 'T':
                if (strlen(attr->value) > 3) {
                    propertyInfo.type = [[NSString alloc] initWithBytes:(attr->value + 2) length:strlen(attr->value) - 3 encoding:NSUTF8StringEncoding];
                }
                break;
            case 'V':
                propertyInfo.name = [NSString stringWithUTF8String:attr->value];
                break;
            case '&':
                // i think this means KVC compliant
                propertyInfo.isKVC = true;
                break;
            //default:
            //    printf("%s\n", attr->name);
        }
    }
    return propertyInfo;
}

@end
