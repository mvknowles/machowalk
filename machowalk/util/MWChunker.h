//
//  MWChunker.h
//  machowalk
//
//  Mark Knowles <mark@mknowles.com.au> 2020-05-20
//  Copyright © 2020 Mark Knowles. 
//

#ifndef MWChunker_h
#define MWChunker_h

@interface MWChunker : NSObject

@property (nonatomic) NSData *data;
@property (nonatomic) NSUInteger dataOffset;
@property (nonatomic) NSString *path;

- (instancetype)init:(NSString*)path;
- (void*)dataChunk:(size_t)type_length;
- (void*)dataChunk:(size_t)type_length increment:(BOOL)increment;
- (NSString*)stringChunk:(NSRange)range;
- (NSString*)readUTF8String;
- (NSString*)readUTF8StringWithMaxLength:(NSUInteger)maxLength;
- (uint8_t)readByte;
- (uint8_t)byteAt:(NSUInteger)position;
- (uint64_t) readUleb128;

@end

#endif /* MWChunker_h */
