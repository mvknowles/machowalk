//
//  MWChunker.m
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#import <Foundation/Foundation.h>

#import "machowalk.h"
#import "MWChunker.h"

@implementation MWChunker

@synthesize dataOffset;
@synthesize data;
@synthesize path;

- (void*)dataChunk:(NSUInteger)type_length {
    return [self dataChunk:type_length increment:true];
}

- (void*)dataChunk:(NSUInteger)type_length increment:(BOOL)increment {
    void *n = malloc(type_length);
    memset(n, '\0', type_length);
    NSRange range = NSMakeRange(dataOffset, type_length);
    [data getBytes:n range:range];
    
    if (increment) {
        dataOffset += type_length;
    }
    return n;
}

- (NSString*)stringChunk:(NSRange)range {
    NSData *subData = [data subdataWithRange:range];
    
    NSString *n = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
    
    return n;
}

- (uint8_t)readByte {
    uint8_t b = [self byteAt:self.dataOffset];
    self.dataOffset++;
    return b;
}

- (NSString*)readUTF8String:(BOOL)checkBounds maxLength:(NSUInteger)maxLength {
    const char* subBytes = data.bytes + self.dataOffset;
    // find the null terminator:
    // we start nullLength at 0 to make sure we don't feed the null to NSString init
    
    debug(@"maxbounds: %lu\n", (unsigned long)maxLength, NULL);
    NSUInteger nullLength = 0;
    while (checkBounds == false || nullLength < maxLength) {
        // this will throw if position invalid
        if ([self readByte] == '\0') {
            break;
        }
        nullLength ++;
    }
    
    return [[NSString alloc] initWithBytes:subBytes length:nullLength encoding:NSUTF8StringEncoding];
}

- (NSString*)readUTF8StringWithMaxLength:(NSUInteger)maxLength {
    return [self readUTF8String:true maxLength:maxLength];
}

- (NSString*)readUTF8String {
    return [self readUTF8String:false maxLength:0];
}

- (uint8_t)byteAt:(NSUInteger)position {
    if (position >= data.length) {
        [NSException raise:@"Chunker OOB" format:@"Chunker position %#lx is OOB", position];
    }
    uint8_t b = ((const char*)data.bytes)[position];
    return b;
}

- (instancetype)init:(NSString*)path {
    self.path = path;
    
    NSError *error = nil;
    self.dataOffset = 0;
    data = [[NSData alloc] initWithContentsOfFile:path  options:NSDataReadingMappedIfSafe error:&error];
 
    if (error != nil) {
        debug(@"Error: %@", error, NULL);
    }
    return self;
}

- (uint64_t) readUleb128 {
    uint64_t result = 0;
    int shift = 0;
    NSUInteger readCount = 0;
    
    while (true) {
        uint8_t b;
        uint64_t low;
        
        // this will throw if we are out of bounds
        b = [self readByte];
        readCount++;
        
        low = b & 0x7f;
        
        // check if our shift will overflow the uint64
        if (shift >= 64 || low << shift >> shift != low) {
            [NSException raise:@"Malformed uleb128" format:@"Shift will result in undefined byte"];
        }
        result |= low << shift;
        shift += 7;
        
        if ((b & 0x80) == 0) {
            break;
        }

        
        
        /*if (*cc < 0x80) {
            break;
        }*/
    }
    
    //printf("r=%llx, readbytes=%lu\n", result,(unsigned long)readCount);

    return result;
}

@end
