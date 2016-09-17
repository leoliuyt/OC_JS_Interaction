//
//  LLWKWebViewVC.m
//  JavaScript&OC
//
//  Created by leoliu on 16/9/16.
//  Copyright © 2016年 LL. All rights reserved.
//

#import "LLWKWebViewVC.h"
#import "WKWebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>

@interface LLWKWebViewVC()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong, nonatomic)   WKWebView                   *webView;
@property (strong, nonatomic)   UIProgressView              *progressView;

@property WKWebViewJavascriptBridge *bridge;

@end

@implementation LLWKWebViewVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"临时的";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    
    [self.view addSubview:self.progressView];
    
    [self loadExamplePage:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)loadExamplePage:(WKWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"wk_interaction" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)gotoPay
{
    NSString *jsStr = [NSString stringWithFormat:@"paySuccess('%@')",@"支付成功"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)gotoShare:(NSDictionary *)aParam
{
    NSString *title = aParam[@"title"];
    NSString *content = aParam[@"content"];
    NSString *url = aParam[@"url"];
    
    NSString *jsStr = [NSString stringWithFormat:@"shareSuccess('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)gotoBack
{
    NSString *jsStr = [NSString stringWithFormat:@"setReturnValue('%@')",@"GoBack"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

//MARK: KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}


//MARK: WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


//MARK:WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
    NSLog(@"body:%@",message.body);
    if ([message.name isEqualToString:@"ShowPic"]) {
        NSLog(@"看大图");
    } else if ([message.name isEqualToString:@"Share"]) {
        NSLog(@"分享");
        [self gotoShare:message.body];
    } else if ([message.name isEqualToString:@"Pay"]) {
        NSLog(@"支付");
        [self gotoPay];
    } else if ([message.name isEqualToString:@"GoBack"]) {
        NSLog(@"返回");
        [self gotoBack];
    }
}

//MARK:layz
- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addScriptMessageHandler:self name:@"ShowPic"];
        [configuration.userContentController addScriptMessageHandler:self name:@"Pay"];
        [configuration.userContentController addScriptMessageHandler:self name:@"Share"];
        [configuration.userContentController addScriptMessageHandler:self name:@"GoBack"];
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 30.0;
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if(!_progressView){
        _progressView = [[UIProgressView alloc]init];
        CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 2)];
        _progressView.tintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor lightGrayColor];
    }
    return _progressView;
}
@end
