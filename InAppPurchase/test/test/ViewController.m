//
//  ViewController.m
//  test
//
//  Created by iGOD on 16/5/4.
//  Copyright © 2016年 gamtee. All rights reserved.
//

#import "ViewController.h"
#import "JavaScriptCore.h"
#import "Payment.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    JavaScriptCore *js = [[JavaScriptCore alloc] initWithPath:@"test.js"];
    Payment *test = [[Payment alloc] init];
    js.context[@"payment"] = test;
    NSLog(@"result1 = %@", [js call:@"testOne" WithArguments:nil]);
    NSLog(@"result1 = %@", [js call:@"testOne" WithArguments:@[@"1"]]);
    NSLog(@"result2 = %@", [js call:@"testTwo" WithArguments:@[@"11", @"22"]]);
    */
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.raywenderlich.inapprage.drummerrage",
                                 @"com.raywenderlich.inapprage.itunesconnectrage",
                                 @"com.raywenderlich.inapprage.nightlyrage",
                                 @"com.raywenderlich.inapprage.studylikeaboss",
                                 @"com.raywenderlich.inapprage.updogsadness",
                                 nil];

    Payment *test = [[Payment alloc] initWithProductIdentifiers:productIdentifiers];
    test.js.object = @"paymentJS";
    test.js.context[@"paymentOC"] = test;
    //[test.js call:@"requestProducts" WithArguments:nil];
    //[test.js call:@"buyProduct" WithArguments:nil];

    //JSValue *function = test.js.context[@"paymentjs"][@"testOne"];
    //NSLog(@"++++++++++++: %@", [test.js call:@"test" WithArguments:@[@10]]);
    //NSLog(@"++++++++++++: %@", [test.js call:@"requestProducts" WithArguments:nil]);

    
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    //NSString *testScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    /*
    JSContext *context = [[JSContext alloc] init];
    context.exceptionHandler = ^(JSContext *conttext, JSValue *exception) {
        [JSContext currentContext].exception = exception;
        NSLog(@"exception: %@", exception);
    };
    
    [context evaluateScript:
     @"\
     function test(p) {\
         return new Promise(function(resolve, reject) {\
             if (p) {\
                 resolve('yes');\
             } else {\
                 reject('no');\
             }\
         });\
     }\
     function testPromise() {\
         test(true).then(function(m){\
             paymentOC.testOneParameter(m);\
         }, function(m){\
             paymentOC.testOneParameter(m);\
         });\
     }\
     "];
    
    context[@"paymentOC"] = test;
    [context[@"testPromise"] callWithArguments:nil];
     
     
     
 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
