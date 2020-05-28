//
//  PromotionViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/04.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class writefiles;
@interface PromotionViewController : UIViewController<UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate> {
    NSUserDefaults *standardUser;
    CGFloat curwidth;
    CGFloat curheigh;
    WKWebView *mainwebview;
    UIActivityIndicatorView *activityView;
    //WKWebView *newwebview;
    NSString *weblinkstring;
    UIBarButtonItem *item;
    writefiles *writefileclass;
}

@end
