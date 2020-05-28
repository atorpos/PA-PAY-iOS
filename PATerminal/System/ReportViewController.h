//
//  ReportViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 5/19/20.
//  Copyright © 2020 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : UIViewController
{
    CGFloat curwidth;
    CGFloat curheigh;
    UIView *mainview;
    NSString *systemurl;
    UITableView *tableview;
    NSUserDefaults *standardef;
    NSString *max_value;
    NSString *week_total;
}

@end

NS_ASSUME_NONNULL_END
