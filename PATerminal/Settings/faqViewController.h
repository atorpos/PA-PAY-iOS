//
//  faqViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class writefiles;
@interface faqViewController : UIViewController<WKUIDelegate, WKNavigationDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    WKWebView *webview;
    UIActivityIndicatorView *activityView;
    IBOutlet UIButton *openinweb;
    IBOutlet UIButton *cancelbutton;
    NSString *weblinkstring;
    writefiles *writefileclass;
}

@end
