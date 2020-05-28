//
//  SecondViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@class LoginViewController;
@class AboutViewController;
@class HelpViewController;
@class faqViewController;
@class announcementsViewController;
@class legalViewController;
@class EditAccountViewController;
@class AllProductViewController;
@class writefiles;
@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    CGFloat curwidth;
    CGFloat curheigh;
    NSUserDefaults *standardUser;
    IBOutlet UIButton *logoutbutton;
    IBOutlet UIButton *registbutton;
    IBOutlet UIButton *twoFAbutton;
    LoginViewController *loginview;
    AboutViewController *aboutview;
    HelpViewController *helpview;
    faqViewController *faqview;
    announcementsViewController *annocview;
    legalViewController *legalview;
    EditAccountViewController *editview;
    AllProductViewController *allview;
    NSString *addressString;
    UILabel *textaddress;
    NSString *accountlabel;
    NSString *locationlabel;
    NSString *loginlabel;
    NSString *logoutlabel;
    LAContext *context;
    int noofsection;
    NSString *securtiytext;
    writefiles *writefileclass;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UISwitch *securityswitch;
@property (strong, nonatomic) IBOutlet UISwitch *modeswitch;
@property (strong, nonatomic) IBOutlet UISwitch *restswitch;
@end

