//
//  Wrapper.m
//  WebViewDemo
//
//  Created by myx on 2021/11/4.
//

#import "Wrapper.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation Wrapper

- (void)foo {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:script];
    
    context[@"print"] = ^(NSString *text) {
        NSLog(@"来自 OC Wrapper 的回调: %@", text);
    };
    
    JSValue *function = context[@"printHello"];
    [function callWithArguments:@[]];
}

@end
