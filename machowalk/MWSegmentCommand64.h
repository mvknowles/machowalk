//
//  MWSegmentCommand64.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSegmentCommand64_h
#define MWSegmentCommand64_h

#import "MWLoadCommand.h"
#import "MWKeyValue.h"
#import "MWSection64.h"

@interface MWSegmentCommand64 : MWLoadCommand
@property (nonatomic) struct segment_command_64 *value;
@property (nonatomic) NSMutableArray<MWSection64*> *sections;
@property (nonatomic) NSString *segmentName;
@end

#endif /* MWSegmentCommand64_h */
