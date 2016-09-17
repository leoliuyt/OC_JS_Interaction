//
//  LLWebViewVC.m
//  JavaScript&OC
//
//  Created by leoliu on 16/9/16.
//  Copyright © 2016年 LL. All rights reserved.
//

#import "LLWebViewVC.h"
#import "WebViewJavascriptBridge.h"

@interface LLWebViewVC()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property WebViewJavascriptBridge* bridge;
@end

@implementation LLWebViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
    [_bridge setWebViewDelegate:self];
    
    [self loadExamplePage:self.webview];
    
    // 添加JS 要调用的Native 功能
    [self registerNativeFunctions];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"interaction" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)registerNativeFunctions
{
    [self registShowPicFunction];
    [self registShareFunction];
    [self registPayFunction];
    [self registGoBackFunction];
}

- (void)registShowPicFunction
{
    // 注册的handler 是供 JS调用Native 使用的。
    [self.bridge registerHandler:@"showBigPicAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"看大图:%@",data);
        NSString *scanResult = @"http://www.baidu.com";
        responseCallback(scanResult);
    }];
}

- (void)registShareFunction
{
    // 注册的handler 是供 JS调用Native 使用的。
    [self.bridge registerHandler:@"shareAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"分享:%@",data);
        NSString *scanResult = @"http://www.baidu.com";
        responseCallback(scanResult);
    }];
}

- (void)registPayFunction
{
    // 注册的handler 是供 JS调用Native 使用的。
    [self.bridge registerHandler:@"payAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"支付:%@",data);
        NSString *scanResult = @"success";
        responseCallback(scanResult);
    }];
}

- (void)registGoBackFunction
{
    // 注册的handler 是供 JS调用Native 使用的。
    __weak LLWebViewVC *weakSelf = self;
    [self.bridge registerHandler:@"goBackAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"返回：%@",data);
        NSString *scanResult = @"返回";
        responseCallback(scanResult);
        [weakSelf.webview goBack];
    }];
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
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

@end
