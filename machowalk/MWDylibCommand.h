//
//  MWDylibCommand.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWDylibCommand_h
#define MWDylibCommand_h

#import "MWLoadCommand.h"

@interface MWDylibCommand : MWLoadCommand
@property (nonatomic) struct dylib_command *value;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *currentVersion;
@property (nonatomic) NSArray<NSString*> *currentVersionParts;
@property (nonatomic) NSString *compatibilityVersion;
@property (nonatomic) NSArray<NSString*> *compatibilityVersionParts;
@end

#endif /* MWDylibCommand_h */
