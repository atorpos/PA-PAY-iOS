//
//  HistoryDetailViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/03/22.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDetailViewController : UIViewController<UIWebViewDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    UIWebView *webview;
    UIActivityIndicatorView *activityView;
    IBOutlet UIButton *openinweb;
    IBOutlet UIButton *cancelbutton;
}
@property (copy) NSString *weblinkstring;
@end
