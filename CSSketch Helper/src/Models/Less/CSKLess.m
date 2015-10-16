//
//  CSKLess.m
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKLess.h"
#import <JavaScriptCore/JavaScriptCore.h>



@implementation CSKLess
+ (void)compileLessStylesheet:(NSString *)stylesheet
                   completion:(LessCompileCompletionBlock)completionBlock  {
    
    NSString *lessScriptPath = [[CSKMainController pluginBundle] pathForResource:@"less-rhino-1.7.5"
                                                                          ofType:@"js"
                                                                     inDirectory:@"external"];
    NSError *error = nil;
    NSString *lessScript = [NSString stringWithContentsOfFile:lessScriptPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    
    if (error) {
        NSLog(@"Error, couldn't read Less script %@", lessScriptPath);
        [CSKMainController displayError:@"Couldn't read Less script!"];
        return;
    }
    
    JSContext *context = [JSContext new];

    NSError *(^errorFromJSError)(id error) = ^(id jsError) {
        NSError *error;
        NSString *errorString = [NSString stringWithFormat:@"%@", jsError];
        NSDictionary *userInfo;
        userInfo = @{
                     NSLocalizedDescriptionKey : errorString
                     };
        error = [NSError errorWithDomain:@"CSK"
                                    code:1020
                                userInfo:userInfo];
        return error;
    };
    
    [context setExceptionHandler:^(JSContext *context, JSValue *exception) {
        NSString *format = [NSString stringWithFormat:@"%@ - %@", exception, exception.toDictionary];
        completionBlock(errorFromJSError(format), nil);
        
    }];
    __block BOOL parserBlockRan = FALSE;
    void (^parserBlock)(JSValue *error, JSValue *output) = ^(JSValue *jsError, JSValue *tree) {
        if (![jsError isNull]) {
            completionBlock(errorFromJSError(jsError), nil);
            return;
        }
        
        JSContext *context = [JSContext currentContext];
        
        context[@"parsedTree"] = tree;
        JSValue *compiledCSS = [context evaluateScript:@"parsedTree.toCSS({})"];
        completionBlock(nil, compiledCSS.toString);
        
        parserBlockRan = true;
    };
    
    [context setObject:parserBlock forKeyedSubscript:@"parserBlock"];
    [context evaluateScript:lessScript];
    
    context[@"lessStylesheet"] = stylesheet;
    [context evaluateScript:@"var parser = new(less.Parser);"];
    [context evaluateScript:@"parser.parse(lessStylesheet, parserBlock);"];
    
    // error in case parser block didn't run;
    if (parserBlockRan == FALSE) {
        completionBlock(errorFromJSError(@"Couldn't run Less Parser!"), nil);
    }
    
}

@end

