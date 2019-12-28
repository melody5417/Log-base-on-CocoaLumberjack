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

#import "YQASLLogger.h"

@protocol YQLogger;

/**
 *  This class provides the ability to capture the ASL (Apple System Logs)
 */
API_DEPRECATED("Use YQOSLogger instead", macosx(10.4,10.12), ios(2.0,10.0), watchos(2.0,3.0), tvos(9.0,10.0))
@interface YQASLLogCapture : NSObject

/**
 *  Start capturing logs
 */
+ (void)start;

/**
 *  Stop capturing logs
 */
+ (void)stop;

/**
 *  The current capture level.
 *  @note Default log level: YQLogLevelVerbose (i.e. capture all ASL messages).
 */
@property (class) YQLogLevel captureLevel;

@end
