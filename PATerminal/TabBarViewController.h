//
//  TabBarViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/09.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstViewController, SecondViewController, ThirdViewController, HistoryViewController, SystemViewController, CNPPopupController, ReportViewController;
@class writefiles;
@interface TabBarViewController : UITabBarController<UITabBarControllerDelegate, UIScrollViewDelegate> {
    FirstViewController *firstview;
    SecondViewController *secondview;
    ThirdViewController *thirdview;
    HistoryViewController *historyview;
    SystemViewController *systemview;
    ReportViewController *reportview;
    writefiles *writefileclass;
    float insetbottom;
    UITabBarController *tabbarcontroller;
    NSUserDefaults *standarddefault;
    NSString *homelabel;
    NSString *reportlabel;
    NSString *historylabel;
    NSString *settinglabel;
    NSTimer *autotimer;
    NSTimer *slidetimer;
    UIView *fullview;
    CGFloat curwidth;
    CGFloat curheigh;
    UITapGestureRecognizer *screentapgesture;
    UIScrollView *adscreenview;
    float repeattime;
}
-(void)tabbarinidle;
-(void)tabbarrestart;
@property (nonatomic, retain) UIPageControl * pageControl;
@end
