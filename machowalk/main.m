//
//  main.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles.
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWMachOFile.h"
#import "util/MWSerializer.h"

uint8_t verbosity = 0;

void debug(NSString *format, ...) {
    //NSString *newFormat = [NSString stringWithFormat:@"%@ %@", @"Log:", format];

    if (verbosity > 0) {

        va_list vargs;
        va_start(vargs, format);
        NSLogv(format, vargs);
        va_end(vargs);
    }
}

int main(int argc, const char * argv[]) {
    //@autoreleasepool {
        NSString *path;
        MWMachOFile *machOFile;
        
        if (argc == 1) {
            // a test file for devel
            path = @"/System/Library/PrivateFrameworks/Sharing.framework/Sharing";
            //path  = @"/System/Library/PrivateFrameworks/SharingXPCServices.framework/SharingXPCServices";
            verbosity = 0;
        } else {
            path = [NSString stringWithUTF8String:argv[1]];
        }
        
        machOFile = [[MWMachOFile alloc] init: path];
        [machOFile process];
        
        MWSerializer *serializer = [MWSerializer new];
        [serializer jsonify:machOFile];
        
    //}
    return 0;
}
