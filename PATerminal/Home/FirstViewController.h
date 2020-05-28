//
//  FirstViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <WebKit/WebKit.h>
#import "Reachability.h"
#import "Product_info+CoreDataProperties.h"
#import <CoreData/CoreData.h>

@class LoginViewController;
@class PromotionViewController;
@class writefiles;
@class setimer;
@class CNPPopupController;
@class papay_frameworks;

@interface FirstViewController : UIViewController <CLLocationManagerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    NSUserDefaults *standardUser;
    UIView *firstpanel;
    UIView *secpanel;
    UIView *thipanel;
    CLLocationManager *locationManager;
    WKWebView *webview;
    UIActivityIndicatorView *activityview;
    Reachability *reachable;
    papay_frameworks *pafw;
    NSString *transitionquery;
    NSString *readtext;
    LoginViewController *loginview;
    PromotionViewController *promoview;
    UILabel *lasttransition;
    UILabel *lasttransitionsc;
    NSString *qrcodequery;
    UIView *showqrview;
    NSString *accountname;
    NSString *totalamount;
    NSString *lasttranscation;
    IBOutlet UILabel *clientname;
    UILabel *terminalidlabel;
    UILabel *maxdollar;
    UISwipeGestureRecognizer *swipeGesture;
    UIPanGestureRecognizer *pangesture;
    UITapGestureRecognizer *tangesture;
    UITapGestureRecognizer *screentapgesture;
    UILongPressGestureRecognizer *longpressrecg;
    NSString *transcationlabel;
    NSString *termainallabel;
    NSString *qrcodelabel;
    writefiles *writefileclass;
    setimer *setimerclass;
    NSTimer *autotimer;
    UIView *fullview;
    NSUserDefaults *shared;
}

@end

