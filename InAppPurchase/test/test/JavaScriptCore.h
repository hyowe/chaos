//
//  JavaScriptCore.h
//  test
//
//  Created by iGOD on 16/5/5.
//  Copyright © 2016年 gamtee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JavaScriptCore : NSObject

@property NSString *path;
@property JSContext *context;
@property NSString *object;

- (id)initWithPath:(NSString *)path;
- (void)setObject:(NSString *)object;
- (id)call:(NSString *)functionName WithArguments:(NSArray *)args;

@end
