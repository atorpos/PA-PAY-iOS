//
//  PromotionViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/04.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "PromotionViewController.h"
//#import <WebKit/WebKit.h>
#import "writefiles.h"

@interface PromotionViewController ()

@end

@implementation PromotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    standardUser = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view, typically from a nib.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"The screen size %f, %f", curwidth, curheigh);
    UIImageView *titleimg = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, curwidth-80, 30)];
    //titleimg.backgroundColor = [UIColor clearColor];
    UIImage *titlelogo = [UIImage imageNamed:@"OpeningPG_logo.png"];
    titleimg.contentMode = UIViewContentModeScaleAspectFit;
    [titleimg setImage:titlelogo];
    self.navigationItem.titleView = titleimg;
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeview:)];
    self.navigationItem.rightBarButtonItem = rightbutton;
    //NSLog(@"%@", weblinkstring);
    weblinkstring = @"https://merchant.pa-sys.com/alipay/promotion/";
    
    activityView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityView.center=self.view.center;
    
    
    
    NSURL *url = [NSURL URLWithString:weblinkstring];
    NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    //mainwebview = [[WKWebView alloc] init];
    //mainwebview.frame = CGRectMake(0, 0, curwidth, curheigh-0);
    mainwebview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-0)];
    [mainwebview loadRequest:requesturl];
    mainwebview.delegate = self;
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
    mainwebview.scrollView.scrollEnabled = YES;
    mainwebview.scrollView.bounces = YES;
    [self.view addSubview:mainwebview];
    
    [self.view addSubview:activityView];
}
-(void)viewDidAppear:(BOOL)animated {
    writefileclass = [[writefiles alloc] init];
    writefileclass.updatelocation = [standardUser objectForKey:@"updatelocation"];
    [writefileclass setpageview:@"promotion.view"];
}
-(IBAction)closeview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *stringlog = [NSString stringWithFormat:@"%@", request.URL.absoluteString];
        NSLog(@"%@", stringlog);
        
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"link %@", webView.request.URL.absoluteString);
    if (![webView.request.URL.absoluteString isEqualToString:weblinkstring]) {
        item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backtoprevious:)];
        [self.navigationItem setLeftBarButtonItem:item];
        [item setEnabled:YES];
    }
    
}
-(IBAction)backtoprevious:(id)sender {
    NSLog(@"back is clicked");
    [item setEnabled:NO];
    [item setTintColor:[UIColor clearColor]];
    NSURL *url = [NSURL URLWithString:weblinkstring];
    NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    [mainwebview loadRequest:requesturl];
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
