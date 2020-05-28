//
//  HistoryDetailViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/03/22.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "HistoryDetailViewController.h"

@interface HistoryDetailViewController ()

@end

@implementation HistoryDetailViewController
@synthesize weblinkstring;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharepage:)];
    
    [self.navigationItem setRightBarButtonItem:item];
    
    NSLog(@"the %@", weblinkstring);
    //weblinkstring = @"https://www.google.com/";
    
    activityView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    
    activityView.center=self.view.center;
    
    
    
    NSURL *url = [NSURL URLWithString:weblinkstring];
    //NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *requesturl = [NSMutableURLRequest requestWithURL:url];
    
    [requesturl setValue:@"iphone" forHTTPHeaderField:@"User-Agent"];
    webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-0)];
    [webview loadRequest:requesturl];
    webview.navigationDelegate = self;
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
-(void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view out");
}

-(IBAction)sharepage:(id)sender {
    
//    UIView *wholeScreen = self.splitViewController.view;
     
    // define the size and grab a UIImage from it
    UIGraphicsBeginImageContextWithOptions(webview.bounds.size, webview.opaque, 0.0);
    [webview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(screengrab, nil, nil, nil);
    
    
//    NSString *theMessage = @"Some text we're sharing with an activity controller";
//    NSArray *items = @[theMessage];
    NSArray *items = @[screengrab];
    UIActivityViewController *AV_controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    [self presentViewController:AV_controller animated:YES completion:^{}];
    
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
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
