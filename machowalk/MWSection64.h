//
//  MWSection64.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWSection64_h
#define MWSection64_h

#import "MWKeyValue.h"
#import "MWMachElement.h"

@interface MWSection64 : MWMachElement
@property (nonatomic) struct section_64 *value;
@property (nonatomic) NSString *sectionName;
@property (nonatomic) NSString *segmentName;
@end

#endif /* MWSection64_h */
