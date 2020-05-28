//
//  SystemViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 11/24/17.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import <WebKit/WebKit.h>

@class WebViewController;
@class LoginViewController;
@class writefiles;
@interface SystemViewController : UIViewController  <UIActionSheetDelegate, WKUIDelegate, WKNavigationDelegate> {
    UIView *bgview;
    CGFloat curwidth;
    CGFloat curheigh;
    CGFloat safeheight;
    NSString *urlstring;
    NSMutableArray *thenamespace;
    NSMutableArray *endpoint;
    NSMutableArray *epstatus;
    NSMutableArray *mixdata;
    NSDictionary *json;
    NSUserDefaults *standardUser;
    NSString *readtext;
    UIView *loadingbgview;
    UIActivityIndicatorView *loadingviewsp;
    NSArray *listtitle;
    NSArray *listsubtitle;
    NSArray *listlink;
    NSArray *listimg;
    WebViewController *showweb;
    LoginViewController *loginview;
    UIView *errorview;
    NSString *pagetitlelabel;
    WKWebView *mainview;
    UIActivityIndicatorView *activityView;
    writefiles *writefileclass;
}
@end
