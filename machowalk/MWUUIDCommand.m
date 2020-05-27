//
//  MWUUIDCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWKeyValue.h"
#import "MWUUIDCommand.h"
#import "MWSerializerHints.h"

@interface NSUUID (Serializable) <MWSerializerHints>
-(NSObject*)normalizerOverride;
@end

@implementation NSUUID (Serializable)
-(NSObject*)normalizerOverride {
    return [self description];
}
@end

@implementation MWUUIDCommand
@synthesize uuid;

-(void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct uuid_command)];
    
    self.uuid = [[NSUUID alloc] initWithUUIDBytes:self.value->uuid];
    
    self.rawStruct = @[
        MAP_STRUCT(uuid_command, cmd),
        MAP_STRUCT(uuid_command, cmdsize)
    ];
}

-(NSString*) description {
    return [self.uuid description];
}

@end
