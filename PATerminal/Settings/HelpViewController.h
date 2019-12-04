//
//  HelpViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class writefiles;
@interface HelpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    CGFloat curwidth;
    CGFloat curheigh;
    NSUserDefaults *standardUser;
    writefiles *writefileclass;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@end
