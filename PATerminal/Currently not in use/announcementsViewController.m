//
//  announcementsViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "announcementsViewController.h"

@interface announcementsViewController ()

@end

@implementation announcementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Announcements", nil);
    self.title = NSLocalizedString(@"Announcements", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
