//
//  WebViewController.m
//  Follow-me
//
//  Created by Oskar Wong on 1/11/18.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize  weblinkstring;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"%@", weblinkstring);
    weblinkstring = @"https://www.google.com/";
    
    activityView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    
    activityView.center=self.view.center;
    
    
    
    NSURL *url = [NSURL URLWithString:weblinkstring];
    NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-0)];
    [webview loadRequest:requesturl];
    webview.UIDelegate = self;
    /*
    if ([websetting isEqualToString:@"social"]) {
        openinweb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        openinweb.frame = CGRectMake(10, 22, 100, 30);
        [openinweb setTitle:@"Open in Web" forState:UIControlStateNormal];
        openinweb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [openinweb addTarget:self action:@selector(openweb:) forControlEvents:UIControlEventTouchUpInside];
        webview.scrollView.scrollEnabled = YES;
        webview.scrollView.bounces = YES;
        [self.view addSubview:openinweb];
    } else {
        
    }*/
    webview.scrollView.scrollEnabled = YES;
    webview.scrollView.bounces = YES;
    [self.view addSubview:webview];
    
    [self.view addSubview:activityView];
    
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [activityView startAnimating];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [activityView setHidden:YES];
}

-(IBAction)cancelpage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)openweb:(id)sender {
    NSURL *url = [NSURL URLWithString:weblinkstring];
    //[[UIApplication sharedApplication] openURL:url];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


