//
//  JavaScriptCore.m
//  test
//
//  Created by iGOD on 16/5/5.
//  Copyright © 2016年 gamtee. All rights reserved.
//

#import "JavaScriptCore.h"

@implementation JavaScriptCore

- (id)initWithPath:(NSString *)path{
    self = [super init];
    if (self != nil) {
        //self.path = path;
        self.path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"js"];
        self.context = [[JSContext alloc] init];
        //异常处理
        self.context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            [JSContext currentContext].exception = exception;
            NSLog(@"exception: %@", exception);
        };
        //加载js环境
        [self.context evaluateScript:[NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil]];
    }

    return self;
}

- (id)call:(NSString *)functionName WithArguments:(NSArray *)args{
    return [self.context[self.object][functionName] callWithArguments:[NSArray arrayWithArray:args]];
}

@end