//
//  ScreenViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/08/29.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "ScreenViewController.h"

@interface ScreenViewController ()

@end

@implementation ScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    UIView *mainview = [[UIView alloc] init];
    mainview.frame = CGRectMake(0, 0, curwidth, curheigh);
    mainview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainview];
    
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
