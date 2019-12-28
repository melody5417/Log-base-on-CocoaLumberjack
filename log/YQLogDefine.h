//
//  YQLogDefine.h
//  QTTranslator
//
//  Created by yiqiwang(王一棋) on 2019/12/27.
//  Copyright © 2019 tencent. All rights reserved.
//

/**
 * 用法
 * 在引用工程的pch中引入，并自定义 log宏， XX为引用工程的前缀
 ```
 #pragma mark -
 #pragma mark Logging

 #import "YQLogDefine.h"

 #define XXLOG       YQLOG
 #define XXERROR     YQERROR
 ```
 */

#ifndef YQLogDefine_h
#define YQLogDefine_h

#import "CocoaLumberjack.h"

#define YQLOG(fmt, ...)     YQLogDebug(@"%s: " fmt, __PRETTY_FUNCTION__, ## __VA_ARGS__)
#define YQERROR(fmt, ...)   YQLogError(@"%s: " fmt, __PRETTY_FUNCTION__, ## __VA_ARGS__)

void setLogLevel(YQLogLevel level);
YQLogLevel logLevel(void);

#endif /* YQLogDefine_h */
