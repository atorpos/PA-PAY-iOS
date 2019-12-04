//
//  tandcViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/25.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstViewController;
@class LoginViewController;
@class writefiles;
@interface tandcViewController : UIViewController<UIWebViewDelegate> {
    UIWebView *mainview;
    UIView *bottomview;
    UIView *topview;
    CGFloat curwidth;
    CGFloat curheigh;
    CGFloat safeheight;
    UIActivityIndicatorView *activityView;
    NSString *tncstring;
    FirstViewController *firstview;
    LoginViewController *loginview;
    NSUserDefaults *standardef;
    UIView *loadingbgview;
    UIActivityIndicatorView *loadingviewsp;
    NSString *readtext;
    writefiles *writefileclass;
}

@property (copy) NSDictionary *jsondm;

@end
