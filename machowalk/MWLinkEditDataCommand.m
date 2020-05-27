//
//  MWLinkEditCommand.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWLinkEditDataCommand.h"

@implementation MWLinkEditDataCommand

-(void) subprocess {
    self.value = [self.machOFile.chunker dataChunk:sizeof(struct linkedit_data_command)];

    self.rawStruct = @[
        MAP_STRUCT(linkedit_data_command, cmd),
        MAP_STRUCT(linkedit_data_command, cmdsize),
        MAP_STRUCT(linkedit_data_command, dataoff),
        MAP_STRUCT(linkedit_data_command, datasize)

    ];
}
-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ dataoff:%0#x datasize:%0#x", self.loadCommandType, [self class], self.value->dataoff, self.value->datasize];
}
@end
