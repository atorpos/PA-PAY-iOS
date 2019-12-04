//
//  EditAccountViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/19.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;
@class writefiles;
@interface EditAccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    NSUserDefaults *standardUser;
    UITableView *tableview;
    NSUserDefaults *standarddef;
    NSString *readtext;
    NSString *signmessage;
    LoginViewController *loginview;
    BOOL storepasswd;
    BOOL newpasswd;
    BOOL repasswd;
    writefiles *writefileclass;
}
@property(nonatomic, strong) IBOutlet UITextField *newpassword;
@property(nonatomic, strong) IBOutlet UITextField *oldpassword;
@property(nonatomic, strong) IBOutlet UITextField *conpassword;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *donebutton;
@property (nonatomic, retain) UIGestureRecognizer *taprecognizer;
@end
