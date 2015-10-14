//
//  CSKDOM.m
//  CSSketch Helper
//
//  Created by John Coates on 10/4/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

#import "CSKDOM.h"
#import "RegExCategories.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface CSKDOM ()

@property (strong) WebView *webView;
@property (strong) JSContext *context;
@property (copy) CSKDOMComputedCallback callbackBlock;
@property (strong) NSString *stylesheet;
@property (strong) NSDictionary *layerTree;
@property (weak) DOMDocument *document;

@end

@implementation CSKDOM

- (instancetype)init {
    self = [self initWithStylesheet:nil callback:nil layerTree:nil];
    [NSException raise:@"Wrong Initializer!" format:@"Use initWithStylesheet:"];
    return nil;
}

- (instancetype)initWithStylesheet:(NSString *)stylesheet
                          callback:(CSKDOMComputedCallback)callbackBlock
                         layerTree:(NSDictionary *)layerTree
{
    self = [super init];
    
    if (self) {
        self.stylesheet = stylesheet;
        self.callbackBlock = callbackBlock;
        self.layerTree = layerTree;
        //static const char* simpleUserAgentStyleSheet = "html,body,div{display:block}head{display:none}body{margin:8px}div:focus,span:focus,a:focus{outline:auto 5px -webkit-focus-ring-color}a:any-link{color:-webkit-link;text-decoration:underline}a:any-link:active{color:-webkit-activelink}";

        // TODO possibly: modify body size for size of page
        NSString *resetDefaultStylesheet = [CSKMainController sharedInstance].embeddedStylesheet;
        
        NSString *HTMLString = [NSString
                                stringWithFormat:@"<html><head><style>%@\n%@</style></head><body></body></html>",
                                resetDefaultStylesheet,
                                stylesheet];
        NSURL *baseURL = [NSURL URLWithString:@"internal"];
        _webView = [WebView new];
        [_webView.mainFrame loadHTMLString:HTMLString baseURL:baseURL];
        _webView.frameLoadDelegate = self;
        
        if (![self inCocoaScript]) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        }
    }
    
    return self;
}

- (void)dealloc {
    self.webView.frameLoadDelegate = nil;
    if (DEBUG){
        NSLog(@"CSKDOM dealloc");
    }
}

- (BOOL)inCocoaScript {
    if (NSClassFromString(@"COSTarget")) {
        return TRUE;
    }
    else {
        return FALSE;
    }
}
- (void)webView:(WebView *)sender
    didFinishLoadForFrame:(WebFrame *)frame {
    DOMDocument *document = frame.DOMDocument;
    DOMElement *body = document.body;

    self.document = document;
    
    // create DOM elements
    [self walkLayerTree:(NSMutableDictionary *)self.layerTree parentElement:body];
    
    // store CSS attributes from DOM elements
    [self walkLayerTreeAndStoreComputedProperties:(NSMutableDictionary *)self.layerTree];
    NSString *finalHTML = document.documentElement.outerHTML;
   
    if (DEBUG && ![CSKMainController inSandbox]) {
        [self writeDebugHTMLFileWithContents:finalHTML];
    }
    
    self.callbackBlock(nil, self.layerTree);
}

- (void)writeDebugHTMLFileWithContents:(NSString *)finalHTML {
    NSString *sourcePath = [NSString stringWithUTF8String:__FILE__];
    NSString *rootProjectPath = [sourcePath stringByAppendingString:@"/../../../../../"].stringByStandardizingPath;
    NSString *debugHTMLPath = [rootProjectPath stringByAppendingPathComponent:@"Examples/debug.html"];
    
    NSLog(@"writing debug file to: %@", debugHTMLPath);
    [finalHTML writeToFile:debugHTMLPath
                atomically:true
                  encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"final document: %@", finalHTML);

}

- (void)walkLayerTree:(NSMutableDictionary *)layerTree parentElement:(DOMElement *)parent {
    DOMElement *element = [self.document createElement:@"layer"];
    [element setAttribute:@"objectID" value:layerTree[@"objectID"]];
    
    CSK_MSLayer *layer = layerTree[@"layer"];
    
    if ([layer isKindOfClass:NSClassFromString(@"MSTextLayer")]) {
        [element setAttribute:@"type" value:@"text"];
    }
    else if ([layer isKindOfClass:NSClassFromString(@"MSArtboardGroup")]) {
        [element setAttribute:@"type" value:@"artboard"];
    }
    
    NSString *name = layerTree[@"name"];
    NSArray *allClasses = [name matches:RX(@"(^|\\s)\\.([^\\s]+)")];
    
    if (allClasses.count) {
        NSString *classes = [allClasses componentsJoinedByString:@" "];
        
        // clean up name
        name = [name stringByReplacingOccurrencesOfString:classes withString:@""];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // strip .
        classes = [classes stringByReplacingOccurrencesOfString:@"." withString:@""];
        
        [element setAttribute:@"class" value:classes];
        
//        if ([classes containsString:@".optIn"]) {
//            layerTree[@"CSSOptIn"] = @(TRUE);
//        }
    }
    
    [element setAttribute:@"name" value:name];
    
    [parent appendChild:element];
    
    NSArray *children = layerTree[@"children"];
    
    if (children) {
        for (NSMutableDictionary *childLayer in children) {
            [self walkLayerTree:childLayer parentElement:element];
        }
    }
    
    layerTree[@"element"] = element;
}

- (void)walkLayerTreeAndStoreComputedProperties:(NSMutableDictionary *)layerTree {
    DOMElement *element = layerTree[@"element"];
    NSDictionary *rules = [self rulesForElement:element];
    layerTree[@"rules"] = rules;
    [layerTree removeObjectForKey:@"element"];
    
    NSArray *children = layerTree[@"children"];
    
    if (children) {
        for (NSMutableDictionary *childLayer in children) {
            [self walkLayerTreeAndStoreComputedProperties:childLayer];
        }
    }
    
    
}

- (NSDictionary *)rulesForElement:(DOMElement *)element {
    DOMDocument *document = self.webView.mainFrame.DOMDocument;
    DOMCSSRuleList *rules = [document getMatchedCSSRules:element pseudoElement:nil];
    
    NSMutableDictionary *properties = [NSMutableDictionary new];

//    NSLog(@"style: %@", element.style.cssText);
    DOMCSSRule *rule;
    for (int i=0; i < rules.length; i++) {
        rule = [rules item:i];
//        NSLog(@"rule: %@", rule.cssText);
        
        if ([rule isKindOfClass:[DOMCSSStyleRule class]]) {
            
            DOMCSSStyleRule *styleRule = (DOMCSSStyleRule *)rule;
            
            DOMCSSStyleDeclaration *declaration = styleRule.style;
            for (int itemIndex=0; itemIndex < declaration.length; itemIndex++) {
                NSString *item = [declaration item:itemIndex];
                NSString *value = [declaration getPropertyValue:item];
                properties[item] = value;
            }
        }
    }
//    NSLog(@"un-matched properties: %@", properties);
    
    NSMutableDictionary *computedProperties = [NSMutableDictionary new];
    
    DOMCSSStyleDeclaration *computedStyle = [document getComputedStyle:element pseudoElement:nil];
//    NSLog(@"computed: %@", computedStyle.cssText);
    for (NSString *property in properties) {
        NSString *computedValue = [computedStyle getPropertyValue:property];
        
        if (!computedValue) {
            NSLog(@"couldn't get computed value for %@", property);
            continue;
        }
        
        computedProperties[property] = computedValue;
    }
    
    // added to all elements
    
    // go through offset parents to find offset
    // relative to document
    int offsetTop = 0;
    int offsetLeft = 0;
    
    DOMElement *currentElement = element;
    
    while (currentElement) {
        offsetTop += currentElement.offsetTop;
        offsetLeft += currentElement.offsetLeft;
        
        currentElement = currentElement.offsetParent;
        
        // stop at artboard or page
        if ([currentElement.tagName isEqualToString:@"artboard"] ||
            [currentElement.tagName isEqualToString:@"page"]
            ) {
            currentElement = nil;
        }
    }
    
    computedProperties[@"offsetTop"] = @(offsetTop);
    computedProperties[@"offsetLeft"] = @(offsetLeft);
    computedProperties[@"offsetParent"] = element.offsetParent;
    

    return computedProperties;
}

@end
