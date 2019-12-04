//
//  TodayViewController.h
//  PATerminal_widget
//
//  Created by oskar wong on 30/7/2019.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController {
    NSUserDefaults *standardUser;
}
@property (nonatomic, retain) IBOutlet UILabel *thetotal;
@end
