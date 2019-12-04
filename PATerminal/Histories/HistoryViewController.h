//
//  HistoryViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 11/24/17.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class HistoryDetailViewController;
@class ScanBarcodeViewController;
@class writefiles;
@interface HistoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    UIView *loadingbgview;
    UIActivityIndicatorView *loadingview;
    NSUserDefaults *standarddefault;
    NSArray *transactioninfo;
    NSString *transcationurl;
    UIView *blankview;
    int noofrow;
    HistoryDetailViewController *historydetview;
    ScanBarcodeViewController *scaninview;
    UIRefreshControl *refreshcontrol;
    NSString *theorderamount;
    UIImageView *paymentview;
    writefiles *writefileclass;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end
