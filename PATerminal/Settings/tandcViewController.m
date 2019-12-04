//
//  tandcViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/25.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "tandcViewController.h"
#import "FirstViewController.h"
#import "LoginViewController.h"
#import "writefiles.h"

@interface tandcViewController ()

@end

@implementation tandcViewController
@synthesize jsondm;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"json dm %@", jsondm);
    // Do any additional setup after loading the view.
    standardef = [NSUserDefaults standardUserDefaults];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    if (@available(iOS 11.0, *)) {
        safeheight = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top + UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 48)];
    if (@available(iOS 11.0, *)) {
        bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, curheigh-safeheight-65, curwidth, 65+UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom)];
    } else {
        // Fallback on earlier versions
    }
    bottomview.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    mainview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-65-safeheight)];
    mainview.backgroundColor = [UIColor whiteColor];
    tncstring  = @"https://merchant.pa-sys.com/alipay/tnc";
    
    
    
    activityView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityView.center=self.view.center;
    
    NSURL *url = [NSURL URLWithString:tncstring];
    NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    [mainview loadRequest:requesturl];
    mainview.delegate = self;
    mainview.scrollView.scrollEnabled = YES;
    mainview.scrollView.bounces = YES;
    [self.view addSubview:mainview];
    [self.view addSubview:topview];
    [self.view addSubview:bottomview];
    [self.view addSubview:activityView];
    
}
-(void)addbutton {
    UIButton *acceptbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptbutton.frame = CGRectMake(curwidth/2, 0, curwidth/2, 65);
    acceptbutton.backgroundColor = [UIColor colorWithRed:0.36 green:0.78 blue:0.83 alpha:1];
    //[acceptbutton setTintColor:[UIColor colorWithRed:0.36 green:0.78 blue:0.83 alpha:1]];
    [acceptbutton setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
    [acceptbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptbutton setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateSelected];
    [acceptbutton addTarget:self action:@selector(accepttnc) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *declinebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    declinebutton.frame = CGRectMake(0, 0, curwidth/2, 65);
    declinebutton.backgroundColor = [UIColor colorWithRed:0.92 green:0.42 blue:0.45 alpha:1];
    [declinebutton setTitle:NSLocalizedString(@"Decline", nil) forState:UIControlStateNormal];
    [declinebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [declinebutton setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateSelected];
    [declinebutton addTarget:self action:@selector(cancelsession) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomview addSubview:declinebutton];
    [bottomview addSubview:acceptbutton];
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"tandc.view"];
    [activityView startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityView setHidden:YES];
    [self addbutton];
}
-(void)cancelsession {
    NSLog(@"cancel session");
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)accepttnc {
    NSLog(@"accpet t and c");
    [self loadingview];
    [standardef setObject:[[jsondm valueForKey:@"request"] valueForKey:@"id"] forKey:@"loginid"];
    [standardef setObject:[[jsondm valueForKey:@"request"] valueForKey:@"time"] forKey:@"requsttime"];
    [standardef setObject:[[jsondm valueForKey:@"response"] valueForKey:@"time"] forKey:@"responsetime"];
    [standardef setObject:[[jsondm valueForKey:@"payload"] valueForKey:@"token"] forKey:@"signtoken"];
    [standardef setObject:[[jsondm valueForKey:@"payload"] valueForKey:@"signature_secret"] forKey:@"signature_secret"];
    [standardef setObject:[[jsondm valueForKey:@"payload"] valueForKey:@"qrcode"] forKey:@"qrcodestring"];
    [standardef setObject:[[jsondm valueForKey:@"payload"] valueForKey:@"merchant_name"] forKey:@"merchant_name"];
    
    NSString *sentaccept = [NSString stringWithFormat:@"token=%@", [[jsondm valueForKey:@"payload"] valueForKey:@"token"]];
    NSLog(@"sent accept %@", sentaccept);
    NSData *postdata = [sentaccept dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[sentaccept length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:tncstring]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self performSelectorOnMainThread:@selector(fetchresponse:) withObject:data waitUntilDone:YES];
        }
    }];
    [task resume];
}
-(void)fetchresponse:(NSData *)responseData {
    
    UIStoryboard *storybar = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    firstview = [storybar instantiateViewControllerWithIdentifier:@"MainView"];
    [self stoploadingview];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSLog(@"tnc data %@", json);
    [self presentViewController:firstview animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadingview {
    loadingbgview = [[UIView alloc] init];
    loadingbgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    loadingbgview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:loadingbgview];
    loadingviewsp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingviewsp setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingviewsp];
    [loadingviewsp startAnimating];
    
}
-(void)stoploadingview {
    [loadingviewsp stopAnimating];
    [loadingviewsp removeFromSuperview];
    [loadingbgview removeFromSuperview];
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
