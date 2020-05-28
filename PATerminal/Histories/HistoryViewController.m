//
//  HistoryViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 11/24/17.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryDetailViewController.h"
#import "writefiles.h"
#import "services.pch"
#import "CNPPopupController.h"
//#import "ScanInvoiceViewController.h"
#import "ScanBarcodeViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
@synthesize tableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    date = [NSDate date];
    ti = [date timeIntervalSince1970];
    recorddate = ti;
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    transcationurl = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL, TRANSACTION_ENDPOINT];
    standarddefault = [NSUserDefaults standardUserDefaults];
    //UIView *mainview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    writefileclass = [[writefiles alloc] init];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SCAN", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showcam)];
    UIBarButtonItem *itemleft = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FILTER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(navtap:)];
    
    getdatpick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navtap:)];
    [getdatpick setNumberOfTapsRequired:1];
    [getdatpick setNumberOfTouchesRequired:1];
    [self.navigationController.navigationBar addGestureRecognizer:getdatpick];
    
    twofingers= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [twofingers setNumberOfTouchesRequired:2];
    [twofingers setNumberOfTapsRequired:1];
    [twofingers setDelegate:self];
    [self.view addGestureRecognizer:twofingers];
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plusdate)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(minusdate)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouch:)];
    [longpress setNumberOfTapsRequired:0];
    [longpress setMinimumPressDuration:1];
    [longpress setDelegate:self];
    
    [self.view addGestureRecognizer:longpress];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.navigationItem setRightBarButtonItem:item];
    }
    
    [self.navigationItem setLeftBarButtonItem:itemleft];
    [self showbutton];
    
}
-(void)viewDidAppear:(BOOL)animated {
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, curwidth, curheigh-105) style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            tableview.backgroundColor = [UIColor blackColor];
        } else {
            tableview.backgroundColor = [UIColor whiteColor];
        }
    } else {
        tableview.backgroundColor = [UIColor whiteColor];
    }
    
    /*
     if (@available(iOS 11.0, *)) {
     self.navigationController.navigationBar.prefersLargeTitles = YES;
     } else {
     // Fallback on earlier versions
     }
     if (@available(iOS 11.0, *)) {
     self.navigationItem.largeTitleDisplayMode = YES;
     } else {
     // Fallback on earlier versions
     }
     */
    refreshcontrol = [[UIRefreshControl alloc] init];
    [tableview addSubview:refreshcontrol];
    [refreshcontrol addTarget:self action:@selector(checktranscation) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:tableview];
    [self loadingview];
    [self checktranscation];
    writefileclass.updatelocation = [standarddefault objectForKey:@"updatelocation"];
    [writefileclass setpageview:@"history.view"];
}
-(void)checktranscation{
    NSTimeInterval _interval=recorddate;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    
     [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", dateString]];
    NSString *posttoken = [NSString stringWithFormat:@"token=%@&date=%@", [standarddefault objectForKey:@"signtoken"], dateString];
    NSLog(@"submit log %@", posttoken);
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:transcationurl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            NSString *newstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"back requeste %@", newstr);
                [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
        } else {
        }
    }];
    
    [task resume];
}
-(void)openpickdate {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    CGFloat safeheight = [UIScreen mainScreen].bounds.size.height - window.safeAreaInsets.top - window.safeAreaInsets.bottom;
    NSDate *today = [NSDate date];
    datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, safeheight-200, self.view.frame.size.width, 200)];
    datepicker.datePickerMode = UIDatePickerModeDate;
    datepicker.backgroundColor = [UIColor whiteColor];
    
    [datepicker setMaximumDate:today];
    [datepicker addTarget:self action:@selector(onDatePickerZValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,safeheight-200,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donepicker:)];
    
    [toolBar setItems:[NSArray arrayWithObjects:flexible,  barButtonDone, nil]];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    
    
    [self.view addSubview:datepicker];
    [self.view addSubview:toolBar];
    
    
}

-(void)onDatePickerZValueChanged:(UIDatePicker *)datePicker {
    NSLog(@"date change %f", [datePicker.date timeIntervalSince1970]);
    recorddate = [datePicker.date timeIntervalSince1970];
    
}
-(void)donepicker:(NSString *)string {
    NSLog(@"done button");
    [self checktranscation];
    [toolBar removeFromSuperview];
    [datepicker removeFromSuperview];
}

-(IBAction)selectdatetypetransaction:(id)sender
{
    
}

-(void)plusdate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *tomorrow = [cal dateByAddingUnit:NSCalendarUnitDay
//                                       value:1
//                                      toDate:[NSDate date]
//                                     options:0];
//    NSLog(@"plus date %@", tomorrow);
    if(recorddate < ti) {
        recorddate = recorddate + 86400;
    }
    [self checktranscation];
}
-(void)minusdate
{
    recorddate = recorddate - 86400;
    [self checktranscation];
}
-(void)showdash {
    NSLog(@"show dash");
}
-(void)showbutton {


}

-(void)showcam {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    scaninview = [storyboard instantiateViewControllerWithIdentifier:@"scaninvoiceview"];
//    historydetview.weblinkstring = [NSString stringWithFormat:@"%@/transaction-detail/?token=%@&request_reference=%@", PRODUCTION_MERCH_URl, [standarddefault objectForKey:@"signtoken"], [[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"request_reference"]];
    [self.navigationController pushViewController:scaninview animated:YES];
}

-(void)fetchdata:(NSData *)requestdata {
    [blankview removeFromSuperview];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    NSLog(@"data %@", json);
    noofrow = (int)[[[json valueForKey:@"payload"] valueForKey:@"transactions"] count];
    if (noofrow != 0) {
        transactioninfo = [[NSArray alloc] initWithArray:[[json valueForKey:@"payload"] valueForKey:@"transactions"]];
        NSLog(@"outptu data %@", [[transactioninfo objectAtIndex:0] valueForKey:@"status"]);
    } else {
        [self norecord];
    }
    [self stoploadingview];
    [refreshcontrol endRefreshing];
    [tableview reloadData];
    
}
-(void) norecord {
//    [tableview removeFromSuperview];
    blankview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    blankview.backgroundColor = [UIColor whiteColor];
    UILabel *annoucelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, curheigh/2-12, curwidth-20, 24)];
    annoucelabel.text = NSLocalizedString(@"NO TODAY'S TRANSCATION", nil);
    
    
    annoucelabel.textAlignment = NSTextAlignmentCenter;
    annoucelabel.adjustsFontSizeToFitWidth = YES;
    annoucelabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:22];
    annoucelabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [blankview addSubview:annoucelabel];
    [self.view addSubview:blankview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return noofrow;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    //UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = nil;
    cell = [tableview dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    if([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"provider"] isEqualToString:@"ALIPAYOFFLINE"]) {
        UIImageView *paymentview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alipay_icon.png"]];
        paymentview.frame = CGRectMake(10, 15, 50, 50);
        [cell.contentView addSubview:paymentview];
    } else if ([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"provider"] isEqualToString:@"PAYPAL"]) {
         UIImageView *paymentview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paypal_c.png"]];
        paymentview.frame = CGRectMake(10, 15, 50, 50);
        [cell.contentView addSubview:paymentview];
    } else if ([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"provider"] isEqualToString:@"CUPOFFLINE"]) {
        UIImageView *paymentview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unionpay_c.png"]];
        paymentview.frame = CGRectMake(10, 15, 50, 50);
        [cell.contentView addSubview:paymentview];
    }else {
        UIImageView *paymentview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wechat_c.png"]];
        paymentview.frame = CGRectMake(10, 15, 50, 50);
        [cell.contentView addSubview:paymentview];
    }
    if([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"status"] isEqualToString:@"2"]) {
        //cell.imageView.image = [UIImage imageNamed:@"alipay_icon_t.png"];
        
        UIImageView *statusview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning_tb.png"]];
        statusview.frame  = CGRectMake(curwidth-40, 25, 30, 30);
        [cell.contentView addSubview:statusview];
        
    } else if ([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"status"] isEqualToString:@"1"]) {
        //cell.imageView.image = [UIImage imageNamed:@"alipay_icon_t.png"];
        UIImageView *statusview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_tb.png"]];
        statusview.frame  = CGRectMake(curwidth-40, 25, 30, 30);
        [cell.contentView addSubview:statusview];
    } else {
        //cell.imageView.image = [UIImage imageNamed:@"alipay_c.png"];
        UIImageView *statusview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waiting_tb.png"]];
        statusview.frame  = CGRectMake(curwidth-40, 25, 30, 30);
        [cell.contentView addSubview:statusview];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    theorderamount = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"order_amount"] doubleValue]]];
    
    
    UILabel *mainlabe = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, curwidth-160, 25)];
    if ([[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Refund"]) {
        mainlabe.text = [NSString stringWithFormat:@"-HKD $%@ %@",theorderamount, NSLocalizedString(@"Refund", nil)];
        mainlabe.textColor = [UIColor colorWithRed:0.92 green:0.42 blue:0.45 alpha:1];
        UILabel *submainlab = [[UILabel alloc] initWithFrame:CGRectMake(curwidth-90, 31, 45, 17)];
        submainlab.text = NSLocalizedString(@"Refund", nil);
        submainlab.font = [UIFont systemFontOfSize:15];
        submainlab.textAlignment = NSTextAlignmentLeft;
        //[cell.contentView addSubview:submainlab];
    } else {
        mainlabe.text = [NSString stringWithFormat:@"HKD $%@",theorderamount];
//        mainlabe.textColor = [UIColor colorWithWhite:0 alpha:1];
    }
    
    mainlabe.textAlignment = NSTextAlignmentLeft;
    mainlabe.adjustsFontSizeToFitWidth = YES;
    mainlabe.font = [UIFont fontWithName:@"Signika-Regular" size:23];
    
    [cell.contentView addSubview:mainlabe];
    
    UILabel *maincidlabe = [[UILabel alloc] initWithFrame:CGRectMake(65, 54, curwidth-75, 15)];
    maincidlabe.text = [NSString stringWithFormat:@"%@", [[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"request_reference"]];
    maincidlabe.textAlignment = NSTextAlignmentLeft;
    maincidlabe.adjustsFontSizeToFitWidth = YES;
    maincidlabe.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
    
    [cell.contentView addSubview:maincidlabe];
    
    UILabel *maintimelabe = [[UILabel alloc] initWithFrame:CGRectMake(65, 36, curwidth-160, 15)];
    NSTimeInterval _interval=[[[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"created_time"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"MM-dd hh:mm"];
    maintimelabe.text = [NSString stringWithFormat:@"%@", [_formatter stringFromDate:date]];
    maintimelabe.textAlignment = NSTextAlignmentLeft;
    maintimelabe.adjustsFontSizeToFitWidth = YES;
    maintimelabe.textColor = [UIColor colorWithWhite:0.4 alpha:0.8];
    maintimelabe.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    
    [cell.contentView addSubview:maintimelabe];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 20)];
//    footerView.backgroundColor = [UIColor blackColor];
//    [footerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProductCellBackground.png"]]];
    tableview.tableFooterView = footerView;
    
    return footerView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    historydetview = [storyboard instantiateViewControllerWithIdentifier:@"historydetailview"];
    historydetview.weblinkstring = [NSString stringWithFormat:@"%@/transaction-detail/?token=%@&request_reference=%@", PRODUCTION_MERCH_URl, [standarddefault objectForKey:@"signtoken"], [[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"request_reference"]];
    [self.navigationController pushViewController:historydetview animated:YES];
}
-(void)loadingview {
    loadingbgview = [[UIView alloc] init];
    loadingbgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    loadingbgview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:loadingbgview];
    loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [loadingview setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingview];
    [loadingview startAnimating];
    
}
-(void)stoploadingview {
    [loadingview stopAnimating];
    [loadingview removeFromSuperview];
    [loadingbgview removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) longTouch: (UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"longTouch UIGestureRecognizerStateBegan");
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"longTouch UIGestureRecognizerStateEnded");
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    recorddate = ti;
    [self checktranscation];
}

-(void)navtap:(UIPanGestureRecognizer *)gestureRecognizer {
    
    [self openpickdate];
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
