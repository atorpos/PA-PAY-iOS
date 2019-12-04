//
//  SystemViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 11/24/17.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "SystemViewController.h"
#import "WebViewController.h"
#import "ScanViewController.h"
#import "LoginViewController.h"
#import "writefiles.h"

@interface SystemViewController ()

@end

@implementation SystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    
    standardUser = [NSUserDefaults standardUserDefaults];
    bgview = [[UIView alloc] init];
    bgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    bgview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgview];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharepage:)];
    
    [self.navigationItem setRightBarButtonItem:item];
    
    writefileclass = [[writefiles alloc] init];
    mainview = [[UIWebView alloc] init];
    mainview.backgroundColor = [UIColor whiteColor];
    //http://gateway.adam-lok.pa-sys.com/alipay/message
    urlstring = [NSString stringWithFormat:@"https://merchant.pa-sys.com/terminal-summary/weekly?token=%@", [standardUser objectForKey:@"signtoken"]];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Report", nil);
    [self.navigationController.navigationBar setTranslucent:NO];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    //tableView.delegate = self;
    //tableView.dataSource = self;
    
//    urlstring = @"https://s3-ap-northeast-1.amazonaws.com/pademo/ankayip/data.json";
//    NSURL *url = [NSURL URLWithString:urlstring];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    NSURLSession *urlsession = [NSURLSession sharedSession];
//    thenamespace = [[NSMutableArray alloc] init];
//    endpoint = [[NSMutableArray alloc] init];
//    epstatus = [[NSMutableArray alloc] init];
//    mixdata = [[NSMutableArray alloc] init];
//    json = [[NSDictionary alloc] init];
//
//    if ([urlsession dataTaskWithRequest:request]) {
//        NSError *err;
//        NSData *urlData = [NSData dataWithContentsOfURL:url];
//        json = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&err];
//        for (NSString *epoint_id in [[json objectForKey:@"data"] allKeys]) {
//            [thenamespace addObject:[[[json objectForKey:@"data"] objectForKey:epoint_id] objectForKey:@"namespace"]];
//            [endpoint addObject:[[[json objectForKey:@"data"] objectForKey:epoint_id] objectForKey:@"endpoint"]];
//            [epstatus addObject:[[[json objectForKey:@"data"] objectForKey:epoint_id] objectForKey:@"status"]];
//            [mixdata addObject:[[[json objectForKey:@"data"] objectForKey:epoint_id] objectForKey:@"data"]];
//        }
//    }
//
//    int i;
//    for (i =0; i < [mixdata count]; i++) {
//
//    }
//    NSLog(@"status %@",epstatus[0]);
    
    //[self.view addSubview:mainview];
    
}
-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"the cg tab bar %f",curheigh);
    
    mainview.frame = CGRectMake(0, 0, curwidth, curheigh-98);
    NSString *poststring = [NSString stringWithFormat:@"token=%@", [standardUser objectForKey:@"signtoken"]];
    NSData *postData = [poststring dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postlength = [NSString stringWithFormat:@"%lu",(unsigned long)[poststring length]];
    NSMutableURLRequest *requests = [[NSMutableURLRequest alloc] init];
    [requests setURL:[NSURL URLWithString:urlstring]];
    [requests setHTTPMethod:@"POST"];
    [requests setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [requests setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requests setHTTPBody:postData];
    
    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *requesturl = [NSURLRequest requestWithURL:url];
    NSError *erro;
    NSString *pagedetect = [[NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&erro] substringToIndex:6];
    NSLog(@"page detail %@", pagedetect);
    if ([pagedetect isEqualToString:@"<!DOCT"]) {
        [mainview loadRequest:requesturl];
        mainview.backgroundColor = [UIColor whiteColor];
        mainview.delegate = self;
    } else {
        [self performSelector:@selector(cancelallsession:) withObject:nil afterDelay:0];
        // wrong format;
    }
    writefileclass = [[writefiles alloc] init];
    writefileclass.updatelocation = [standardUser objectForKey:@"updatelocation"];
    [writefileclass setpageview:@"report.view"];
    //NSURLRequest *urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    
    //[self checkinfo];
}
-(void)checkinfo{
    [self loadingview];
    NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standardUser objectForKey:@"signtoken"]];
    NSLog(@"%@", posttoken);
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlstring]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"QR %@", self->readtext);
            if (![self->readtext isEqualToString:@"no value"]) {
                [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
            } else {
                NSLog(@"no value");
            }
        } else {
        }
    }];
    
    [task resume];
}
-(void)fetchdata:(NSData *)requestdata {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    if([[[json valueForKey:@"response"] valueForKey:@"code"] integerValue] != 200) {
        //[self performSelectorOnMainThread:@selector(cancelallsession:) withObject:nil waitUntilDone:YES];
        [mainview removeFromSuperview];
        errorview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
        errorview.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:errorview];
        [self stoploadingview];
    } else {
        
        listtitle = [[NSArray alloc] initWithArray:[[json valueForKey:@"payload"] valueForKey:@"title"]];
        listsubtitle = [[NSArray alloc] initWithArray:[[json valueForKey:@"payload"] valueForKey:@"subtitle"]];
        listlink  = [[NSArray alloc]initWithArray:[[json valueForKey:@"payload"] valueForKey:@"link"]];
        listimg = [[NSArray alloc] initWithArray:[[json valueForKey:@"payload"] valueForKey:@"img"]];
        NSLog(@"show list %@", listtitle);
        
        [self stoploadingview];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated {
    [mainview removeFromSuperview];
    [errorview removeFromSuperview];
}
-(void)loadingview {
    loadingbgview = [[UIView alloc] init];
    loadingbgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    loadingbgview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1];
    [self.view addSubview:loadingbgview];
    loadingviewsp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingviewsp setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingviewsp];
    [loadingviewsp startAnimating];
}
-(void)stoploadingview {
    [loadingviewsp stopAnimating];
    [loadingviewsp removeFromSuperview];
    [loadingbgview removeFromSuperview];
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    [self loadingview];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [bgview addSubview:mainview];
    [self stoploadingview];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *newurl = request.URL;
    NSString *urlstring = newurl.absoluteString;
    NSLog(@"theurl string %@ - %ld", urlstring, (long)navigationType);
    
    if(navigationType == UIWebViewNavigationTypeOther) {
        NSLog(@"click others %@", urlstring);
    }
    
    if ([urlstring isEqualToString:@""]) {
        
        return NO;
    }
    return YES;
}
-(void)cancelallsession:(id)sender {
    NSLog(@"logout");
    [standardUser removeObjectForKey:@"MerchID"];
    [standardUser removeObjectForKey:@"loginid"];
    [standardUser removeObjectForKey:@"requsttime"];
    [standardUser removeObjectForKey:@"responsetime"];
    [standardUser removeObjectForKey:@"signtoken"];
    [standardUser removeObjectForKey:@"signature_secret"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    loginview = [storyboard instantiateViewControllerWithIdentifier:@"loginview"];
    
    [self presentViewController:loginview animated:YES completion:nil];
    
}

-(IBAction)sharepage:(id)sender {
    
//    UIView *wholeScreen = self.splitViewController.view;
     
    // define the size and grab a UIImage from it
    UIGraphicsBeginImageContextWithOptions(mainview.bounds.size, mainview.opaque, 0.0);
    [mainview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(screengrab, nil, nil, nil);
    
    
//    NSString *theMessage = @"Some text we're sharing with an activity controller";
//    NSArray *items = @[theMessage];
    NSArray *items = @[screengrab];
    UIActivityViewController *AV_controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    AV_controller.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeOpenInIBooks, UIActivityTypePostToFacebook, UIActivityTypeAssignToContact, UIActivityTypeAirDrop];
    
    [self presentViewController:AV_controller animated:YES completion:^{}];

    NSLog(@"no items");
    
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

@end
