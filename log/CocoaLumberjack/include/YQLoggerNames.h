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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *YQLoggerName NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT YQLoggerName const YQLoggerNameASL NS_SWIFT_NAME(YQLoggerName.asl); // YQASLLogger
FOUNDATION_EXPORT YQLoggerName const YQLoggerNameTTY NS_SWIFT_NAME(YQLoggerName.tty); // YQTTYLogger
FOUNDATION_EXPORT YQLoggerName const YQLoggerNameOS NS_SWIFT_NAME(YQLoggerName.os); // YQOSLogger
FOUNDATION_EXPORT YQLoggerName const YQLoggerNameFile NS_SWIFT_NAME(YQLoggerName.file); // YQFileLogger

NS_ASSUME_NONNULL_END
