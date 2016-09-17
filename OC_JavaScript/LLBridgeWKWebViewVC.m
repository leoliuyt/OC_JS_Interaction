//
//  LLBridgeWKWebViewVC.m
//  OC_JavaScript
//
//  Created by leoliu on 16/9/16.
//  Copyright © 2016年 LL. All rights reserved.
//

#import "LLBridgeWKWebViewVC.h"
#import "WKWebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>
@interface LLBridgeWKWebViewVC()<WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic)   WKWebView                   *webView;
@property (strong, nonatomic)   UIProgressView              *progressView;

@property WKWebViewJavascriptBridge *bridge;

@end

@implementation LLBridgeWKWebViewVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"临时的";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    [self registerNativeFunctions];
    
    [self.view addSubview:self.progressView];
    
    [self loadExamplePage:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)rightClick
{
    [_bridge callHandler:@"registerInJSFunction" data:@"在js中注册，oc中调用" responseCallback:^(id responseData) {
        NSLog(@"调用完JS后的回调：%@",responseData);
    }];
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)loadExamplePage:(WKWebView*)webView {
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
    __weak LLBridgeWKWebViewVC *weakSelf = self;
    [self.bridge registerHandler:@"goBackAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"返回：%@",data);
        NSString *scanResult = @"返回";
        responseCallback(scanResult);
        [weakSelf.webView goBack];
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

//MARK:layz
- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        
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
