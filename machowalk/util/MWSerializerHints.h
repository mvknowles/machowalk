//
//  MWSerializerHints.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSerializerHints_h
#define MWSerializerHints_h

#import <Foundation/Foundation.h>

@protocol MWSerializerHints
@optional
-(NSObject*)normalizerOverride;
+(NSSet<NSString*>*)dontSerialize;
@end

#endif /* MWSerializerHints_h */
