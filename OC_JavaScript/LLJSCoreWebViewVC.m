//
//  LLJSCoreWebViewVC.m
//  OC_JavaScript
//
//  Created by leoliu on 16/9/16.
//  Copyright © 2016年 LL. All rights reserved.
//

#import "LLJSCoreWebViewVC.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface LLJSCoreWebViewVC()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation LLJSCoreWebViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadExamplePage:self.webView];
    
    // 添加JS 要调用的Native 功能
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"jscore_interaction" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)replaceJSFunction
{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [self replacePay:context];
    [self replaceShare:context];
    [self replaceGoBack:context];
    [self replaceShowPic:context];
}

- (void)replaceShare:(JSContext *)context
{
    context[@"share"] = ^(){
        NSArray *args = [JSContext currentArguments];
        if (args.count < 3) {
            return ;
        }
        NSString *title = [args[0] toString];
        NSString *content = [args[1] toString];
        NSString *url = [args[2] toString];
        // 在这里执行分享的操作
        NSString *result = [NSString stringWithFormat:@"shareSuccess('%@','%@','%@')",title,content,url];
        [[JSContext currentContext] evaluateScript:result];
    };
}

- (void)replaceShowPic:(JSContext *)context
{
    context[@"showPic"] = ^(){
        NSLog(@"产看大图");
    };
}

- (void)replacePay:(JSContext *)context
{
    context[@"pay"] = ^(){
        [[JSContext currentContext][@"paySuccess"] callWithArguments:@[@"支付成功"]];
    };
}

- (void)replaceGoBack:(JSContext *)context
{
    __weak LLJSCoreWebViewVC *weakSelf = self;
    context[@"goBack"] = ^(){
        [weakSelf.webView goBack];
    };
}

//MARK: UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self replaceJSFunction];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}


@end
