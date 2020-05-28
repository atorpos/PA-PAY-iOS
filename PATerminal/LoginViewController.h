//
//  LoginViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class FirstViewController;
@class tandcViewController;
@interface LoginViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    CLLocationManager *locationManager;
    FirstViewController *firstview;
    tandcViewController *tncview;
    NSString *readtext;
    NSString *signtime;
    NSString *signid;
    NSUserDefaults *standardef;
    NSString *errorstr;
    UIView *loadingbgview;
    UIActivityIndicatorView *loadingviewsp;
    NSString *transcationurl;
    UIView *loginbgview;
    UIImageView *clickedimgview;
    NSString *ischeck;
    UIButton *forgetpasswordbutton;
    UIButton *signupbutton;
    UIButton *forgetbutton;
    int noofrow;
}
@property (nonatomic, retain) IBOutlet UITextField *merchantid;
@property (nonatomic, retain) IBOutlet UITextField *terminalid;
@property (nonatomic, retain) IBOutlet UITextField *passwdfld;
@property (nonatomic, retain) IBOutlet UIButton *loginbutton;
@property (nonatomic, retain) IBOutlet UIButton *regisbutton;
@property (nonatomic, retain) IBOutlet UIButton *forgetpasswd;
@property (nonatomic, retain) IBOutlet UIButton *qrloginbutton;
@property (nonatomic, retain) UIGestureRecognizer *taprecognizer;

-(IBAction)sendlogin:(id)sender;
-(IBAction)backgroundclick:(id)sender;


@end
