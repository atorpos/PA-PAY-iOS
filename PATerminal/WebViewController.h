//
//  WebViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 1/11/18.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    WKWebView *webview;
    UIActivityIndicatorView *activityView;
    IBOutlet UIButton *openinweb;
    IBOutlet UIButton *cancelbutton;
}
@property (copy) NSString *weblinkstring;
@end
