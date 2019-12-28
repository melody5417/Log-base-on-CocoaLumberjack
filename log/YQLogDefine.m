//
//  YQLogDefine.m
//  QTTranslator
//
//  Created by yiqiwang(王一棋) on 2019/12/27.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "YQLogDefine.h"

static YQLogLevel _yqLogLevel = YQLogLevelOff;

void setLogLevel(YQLogLevel level) {
    _yqLogLevel = level;
}

YQLogLevel logLevel(void) {
    return _yqLogLevel;
}
