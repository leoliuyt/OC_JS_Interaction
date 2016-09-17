//
//  LLURLWebViewVC.m
//  OC_JavaScript
//
//  Created by leoliu on 16/9/16.
//  Copyright © 2016年 LL. All rights reserved.
//

#import "LLURLWebViewVC.h"
@interface LLURLWebViewVC()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LLURLWebViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadExamplePage:self.webView];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"url_interaction" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void)gotoPay
{
    NSString *jsStr = [NSString stringWithFormat:@"paySuccess('%@')",@"支付成功"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)gotoShare:(NSURL *)aURL
{
    NSArray *params =[aURL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    
    NSString *title = tempDic[@"title"];
    NSString *content = tempDic[@"content"];
    NSString *url = tempDic[@"url"];
    
    NSString *jsStr = [NSString stringWithFormat:@"shareSuccess('%@','%@','%@')",title,content,url];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)gotoBack
{
    NSString *jsStr = [NSString stringWithFormat:@"setReturnValue('%@')",@"GoBack"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)handleAction:(NSURL *)aURL
{
    NSString *host = [aURL host];
    if ([host isEqualToString:@"showpic"]) {
        NSLog(@"看大图");
    } else if ([host isEqualToString:@"share"]) {
        NSLog(@"分享");
        [self gotoShare:aURL];
    } else if ([host isEqualToString:@"pay"]) {
        NSLog(@"支付");
        [self gotoPay];
    } else if ([host isEqualToString:@"goback"]) {
        NSLog(@"返回");
        [self gotoBack];
    }
}

//MARK: UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *URL = request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"customprotocol"]) {
        [self handleAction:URL];
        return NO;
    }
    
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
