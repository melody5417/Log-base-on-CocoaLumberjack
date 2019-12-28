// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2019, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

#import "../YQFileLogger+Internal.h"
#import "YQFileLogger+Buffering.h"

#import <sys/mount.h>

static const NSUInteger kYQDefaultBufferSize = 4096; // 4 kB, block f_bsize on iphone7
static const NSUInteger kYQMaxBufferSize = 1048576; // ~1 mB, f_iosize on iphone7

// Reads attributes from base file system to determine buffer size.
// see statfs in sys/mount.h for descriptions of f_iosize and f_bsize.
// f_bsize == "default", and f_iosize == "max"
static inline NSUInteger p_YQGetDefaultBufferSizeBytesMax(const BOOL max) {
    struct statfs *mountedFileSystems = NULL;
    int count = getmntinfo(&mountedFileSystems, 0);

    for (int i = 0; i < count; i++) {
        struct statfs mounted = mountedFileSystems[i];
        const char *name = mounted.f_mntonname;

        // We can use 2 as max here, since any length > 1 will fail the if-statement.
        if (strnlen(name, 2) == 1 && *name == '/') {
            return max ? (NSUInteger)mounted.f_iosize : (NSUInteger)mounted.f_bsize;
        }
    }

    return max ? kYQMaxBufferSize : kYQDefaultBufferSize;
}

static NSUInteger YQGetMaxBufferSizeBytes() {
    static NSUInteger maxBufferSize = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        maxBufferSize = p_YQGetDefaultBufferSizeBytesMax(YES);
    });
    return maxBufferSize;
}

static NSUInteger YQGetDefaultBufferSizeBytes() {
    static NSUInteger defaultBufferSize = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBufferSize = p_YQGetDefaultBufferSizeBytesMax(NO);
    });
    return defaultBufferSize;
}

@interface YQBufferedProxy : NSProxy

@property (nonatomic) YQFileLogger *fileLogger;
@property (nonatomic) NSOutputStream *buffer;

@property (nonatomic) NSUInteger maxBufferSizeBytes;
@property (nonatomic) NSUInteger currentBufferSizeBytes;

@end

@implementation YQBufferedProxy

- (instancetype)initWithFileLogger:(YQFileLogger *)fileLogger {
    _fileLogger = fileLogger;
    _maxBufferSizeBytes = YQGetDefaultBufferSizeBytes();
    [self flushBuffer];

    return self;
}

- (void)dealloc {
    dispatch_block_t block = ^{
        [self lt_sendBufferedDataToFileLogger];
        self.fileLogger = nil;
    };

    if ([self->_fileLogger isOnInternalLoggerQueue]) {
        block();
    } else {
        dispatch_sync(self->_fileLogger.loggerQueue, block);
    }
}

#pragma mark - Buffering

- (void)flushBuffer {
    [_buffer close];
    _buffer = [NSOutputStream outputStreamToMemory];
    [_buffer open];
    _currentBufferSizeBytes = 0;
}

- (void)lt_sendBufferedDataToFileLogger {
    NSData *data = [_buffer propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [_fileLogger lt_logData:data];
    [self flushBuffer];
}

#pragma mark - Logging

- (void)logMessage:(YQLogMessage *)logMessage {
    NSData *data = [_fileLogger lt_dataForMessage:logMessage];
    NSUInteger length = data.length;
    if (length == 0) {
        return;
    }

#ifndef DEBUG
    __unused
#endif
    NSInteger written = [_buffer write:[data bytes] maxLength:length];
    NSAssert(written == (NSInteger)length, @"Failed to write to memory buffer.");

    _currentBufferSizeBytes += length;

    if (_currentBufferSizeBytes >= _maxBufferSizeBytes) {
        [self lt_sendBufferedDataToFileLogger];
    }
}

- (void)flush {
    // This method is public.
    // We need to execute the rolling on our logging thread/queue.

    dispatch_block_t block = ^{
        @autoreleasepool {
            [self lt_sendBufferedDataToFileLogger];
            [self.fileLogger flush];
        }
    };

    // The design of this method is taken from the YQAbstractLogger implementation.
    // For extensive documentation please refer to the YQAbstractLogger implementation.

    if ([self.fileLogger isOnInternalLoggerQueue]) {
        block();
    } else {
        dispatch_queue_t globalLoggingQueue = [YQLog loggingQueue];
        NSAssert(![self.fileLogger isOnGlobalLoggingQueue], @"Core architecture requirement failure");

        dispatch_sync(globalLoggingQueue, ^{
            dispatch_sync(self.fileLogger.loggerQueue, block);
        });
    }
}

#pragma mark - Properties

- (void)setMaxBufferSizeBytes:(NSUInteger)newBufferSizeBytes {
    _maxBufferSizeBytes = MIN(newBufferSizeBytes, YQGetMaxBufferSizeBytes());
}

#pragma mark - Wrapping

- (YQFileLogger *)wrapWithBuffer {
    return (YQFileLogger *)self;
}

- (YQFileLogger *)unwrapFromBuffer {
    return (YQFileLogger *)self.fileLogger;
}

#pragma mark - NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.fileLogger methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.fileLogger respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.fileLogger];
}

@end

@implementation YQFileLogger (Buffering)

- (instancetype)wrapWithBuffer {
    return (YQFileLogger *)[[YQBufferedProxy alloc] initWithFileLogger:self];
}

- (instancetype)unwrapFromBuffer {
    return self;
}

@end
