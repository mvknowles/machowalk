//
//  MWMachOFile.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "MWMachOFile.h"
#import "MWMachHeader64.h"

@implementation MWMachOFile

@synthesize stringTable;
@synthesize stringTableByOffset;
@synthesize symbolTableEntries;
@synthesize chunker;
@synthesize header;
@synthesize loadCommands;
@synthesize path;

-(instancetype)init:(NSString*)path {
    self.path = path;
    return self;
}

-(void)process {
    self.chunker = [[MWChunker alloc] init:path];
    
    self.header = [[MWMachHeader64 alloc] init:self];
    [header process];
}

-(NSString*)path {
    return [self.chunker path];
}

+(NSSet<NSString*>*)dontSerialize {
    return [NSSet setWithObjects:@"chunker", nil];
}
@end
