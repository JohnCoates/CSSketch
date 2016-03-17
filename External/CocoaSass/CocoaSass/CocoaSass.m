//
//  CocoaSass.m
//  CocoaSass
//
//  Created by John Coates on 1/31/16.
//  Copyright © 2016 John Coates. All rights reserved.
//

#import "CocoaSass.h"
#include <sass/context.h>

@implementation CocoaSass

+ (NSString *)compileSass:(NSString *)contents
                extension:(NSString *)extension
                    error:(NSError **)errorOut {
    struct Sass_Data_Context *context;
//    sass_option_set_include_path
//    sass_option_set_include_path
    
    // pass memory ownership to libsass
    char *contentsCopy = strdup(contents.UTF8String);
    context = sass_make_data_context(contentsCopy);
    
    struct Sass_Options *options = sass_data_context_get_options(context);
    sass_option_set_output_style(options, SASS_STYLE_NESTED);
    sass_option_set_precision(options, 5);
    
    // .sass = true, .scss = false
    if ([extension isEqualToString:@"sass"]) {
        sass_option_set_is_indented_syntax_src(options, true);
    }
    else {
        sass_option_set_is_indented_syntax_src(options, false);
    }
    
    
    struct Sass_Compiler *compiler = sass_make_data_compiler(context);
    sass_compiler_parse(compiler);
    sass_compiler_execute(compiler);
    
    int errorStatus = sass_context_get_error_status((struct Sass_Context *)context);
    if (errorStatus) {
        const char *errorMessage = sass_context_get_error_message((struct Sass_Context *)context);
        NSString *errorString;
        
        if (errorMessage) {
            errorString = [NSString stringWithFormat:@"Error compiling Sass #%d: %s",
                           errorStatus,
                           errorMessage];
        }
        else {
            errorString = [NSString stringWithFormat:@"Error compiling Sass #%d", errorStatus];
        }
        
        *errorOut = [self errorWithMessage:errorString];
        sass_delete_compiler(compiler);
        return nil;
    }
    
    const char *output = sass_context_get_output_string((struct Sass_Context *)context);
    if (!output) {
        NSString *errorString = [NSString stringWithFormat:@"Couldn't generate Sass output. Error code (%d)", errorStatus];
        *errorOut = [self errorWithMessage:errorString];
        NSLog(@"%@", errorString);
        sass_delete_compiler(compiler);
        return nil;
        
    }
    NSString *compiledContents = [NSString stringWithUTF8String:output];
    sass_delete_compiler(compiler);
    
    return compiledContents;
}

+ (NSError *)errorWithMessage:(NSString *)message {
    NSError *error;
    NSDictionary *userInfo;
    
    userInfo = @{
                 NSLocalizedDescriptionKey : message
                 };
    error = [NSError errorWithDomain:@"CSKSass"
                                code:801
                            userInfo:userInfo];
    
    return error;
}


@end
