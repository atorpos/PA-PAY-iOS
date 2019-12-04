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
    
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    transcationurl = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL, TRANSACTION_ENDPOINT];
    standarddefault = [NSUserDefaults standardUserDefaults];
    //UIView *mainview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    writefileclass = [[writefiles alloc] init];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(showcam)];
    
    [self.navigationItem setRightBarButtonItem:item];
    [self showbutton];
    
}
-(void)viewDidAppear:(BOOL)animated {
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, curwidth, curheigh-105) style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundColor = [UIColor whiteColor];
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
    NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standarddefault objectForKey:@"signtoken"]];
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
-(void)showbutton {
    

}
-(void)showcam {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    scaninview = [storyboard instantiateViewControllerWithIdentifier:@"scaninvoiceview"];
//    historydetview.weblinkstring = [NSString stringWithFormat:@"%@/transaction-detail/?token=%@&request_reference=%@", PRODUCTION_MERCH_URl, [standarddefault objectForKey:@"signtoken"], [[transactioninfo objectAtIndex:indexPath.row] valueForKey:@"request_reference"]];
    [self.navigationController pushViewController:scaninview animated:YES];
}

-(void)fetchdata:(NSData *)requestdata {
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
    [tableview removeFromSuperview];
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
    } else {
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
        mainlabe.textColor = [UIColor colorWithWhite:0 alpha:1];
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
    loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingview setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingview];
    [loadingview startAnimating];
    
}
-(void)stoploadingview {
    [loadingview stopAnimating];
    [loadingview removeFromSuperview];
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
