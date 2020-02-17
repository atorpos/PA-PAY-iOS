//
//  TabBarViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/09.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "TabBarViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "SystemViewController.h"
#import "HistoryViewController.h"
#import "CNPPopupController.h"
#import "writefiles.h"
@interface TabBarViewController () <CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

@end

#define kSetidleTimer @"3000.0"

@implementation TabBarViewController
@synthesize pageControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat cgheight = self.tabBar.frame.size.height;
    CGFloat cgbtwidth = self.view.frame.size.width/5;
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    
    UIWindow *mainwindow = [[[UIApplication sharedApplication] delegate] window];
    
    //detact the x and new ipad pro
    
    if (@available(iOS 11.0, *)) {
        NSLog(@"detect %f", mainwindow.safeAreaInsets.bottom);
        insetbottom = mainwindow.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    
    standarddefault = [NSUserDefaults standardUserDefaults];
    if ([[standarddefault objectForKey:@"systemlanguage"] isEqualToString:@"zh"]) {
        homelabel = @"主頁";
        reportlabel = @"報告";
        historylabel = @"過往交易";
        settinglabel = @"設定";
    } else {
        homelabel = @"Home";
        reportlabel = @"Reports";
        historylabel = @"History";
        settinglabel = @"Settings";
    }
    NSLog(@"the tabbar %@", homelabel);
    [self setUpTabbar];
    // Do any additional setup after loading the view.
    UIImage *buttonImage = [UIImage imageNamed:@"pay.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"pay.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, cgbtwidth+4, cgheight+8);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(openview:) forControlEvents:UIControlEventTouchUpInside];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat heightDifference = cgheight - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        if (insetbottom == 34) {
            center.y = center.y - insetbottom;
        } else if(insetbottom == 20.0){
            center.y = center.y - insetbottom+5;
        }else {
            center.y = center.y - heightDifference/2.0;
        }
        button.center = center;
    }
    
    [self.view addSubview:button];
}
-(void) viewDidAppear:(BOOL)animated {
//    [self settimer:kSetidleTimer];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    NSLog(@"touch count %lu", (unsigned long)[touch tapCount]);
    if([touch tapCount] > 0) {
        NSLog(@"reset time on tab");
        [autotimer invalidate];
        autotimer = nil;
        [self settimer:@"300.0"];
    }
}
-(void) setUpTabbar {
    firstview = [[FirstViewController alloc] init];
    firstview.title = NSLocalizedString(@"Home", nil);
    firstview.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", nil) image:[UIImage imageNamed:@"home_button"] tag:0];
    
    UINavigationController *firstNavController = [[UINavigationController alloc] initWithRootViewController:firstview];
    
    secondview = [[SecondViewController alloc] init];
    secondview.title = NSLocalizedString(@"Settings", nil);
    secondview.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"setting"] tag:2];
    UINavigationController *secondNavController = [[UINavigationController alloc] initWithRootViewController:secondview];
    
    thirdview = [[ThirdViewController alloc] init];
    
    thirdview.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:1];
    UINavigationController *thirdNavController = [[UINavigationController alloc] initWithRootViewController:thirdview];
    
    systemview = [[SystemViewController alloc] init];
    systemview.title = NSLocalizedString(@"Reports", nil);
    systemview.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Reports", nil) image:[UIImage imageNamed:@"cloud"] tag:3];
    UINavigationController *forthNavController = [[UINavigationController alloc] initWithRootViewController:systemview];
    
    historyview = [[HistoryViewController alloc] init];
    historyview.title = NSLocalizedString(@"Histories", nil);
    historyview.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"History", nil) image:[UIImage imageNamed:@"history"] tag:4];
    UINavigationController *fifthNavController = [[UINavigationController alloc] initWithRootViewController:historyview];
    //historyview.tabBarItem.badgeValue = @"1";
    
    
    
    tabbarcontroller = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabbarcontroller.viewControllers = [[NSArray alloc] initWithObjects:firstNavController,forthNavController , thirdNavController, fifthNavController ,secondNavController, nil];
    tabbarcontroller.delegate = self;
    
    [self.view addSubview:tabbarcontroller.view];
    
}

-(void)settimer:(id)sender
{
    float timetode = [sender floatValue];
    autotimer = [NSTimer scheduledTimerWithTimeInterval:timetode target:self selector:@selector(showscreen) userInfo:nil repeats:NO];
    //autotimer = [NSTimer timerWithTimeInterval:timetode target:self selector:@selector(showscreen) userInfo:nil repeats:YES];
}
-(void)showscreen {
    NSLog(@"show screen");repeattime = 0;
    [autotimer invalidate];
    autotimer = nil;
    [self showPopupwithStyle:CNPPopupStyleFullscreen];
}

-(void)showPopupwithStyle:(CNPPopupStyle)popupStyle
{
    int imgcount = (int)[[standarddefault objectForKey:@"ad_screensaver"] count];
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"screensaver.view"];
    adscreenview = [[UIScrollView alloc] init];
    adscreenview.frame = CGRectMake(0, 0, curwidth, curheigh);
    adscreenview.contentSize = CGSizeMake(curwidth*imgcount, curheigh);
    adscreenview.scrollEnabled = YES;
    adscreenview.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0];
    adscreenview.showsHorizontalScrollIndicator = YES;
    adscreenview.pagingEnabled = YES;
    adscreenview.delegate = self;
    screentapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closescreen)];
    [adscreenview addGestureRecognizer:screentapgesture];
    
    
    for (int i = 0; i < imgcount; i++) {
        NSLog(@"looping");
        [self putscreen:i];
    }
    
    slidetimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(slidescreen) userInfo:nil repeats:YES];
    self.popupController = [[CNPPopupController alloc] initWithContents:@[adscreenview]];
    self.popupController.theme = [CNPPopupTheme screenTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}
-(void)putscreen:(int)sender {
    
    NSString *fullink = [[standarddefault objectForKey:@"ad_screensaver"] objectAtIndex:sender];
    NSArray *namearray = [fullink componentsSeparatedByString:@"/"];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentDirectory, [namearray lastObject]];
    NSLog(@"file path %@", filepath);
    NSData *imgdata = [NSData dataWithContentsOfFile:filepath];
    UIImage *readimg = [UIImage imageWithData:imgdata];
    UIImageView *img_screen = [[UIImageView alloc] init];
    img_screen.layer.cornerRadius = 5;
    img_screen.layer.masksToBounds = true;
    img_screen.frame = CGRectMake(curwidth*sender, 0, curwidth, curheigh);
    img_screen.contentMode = UIViewContentModeScaleAspectFit;
    [img_screen setImage:readimg];
    [adscreenview addSubview:img_screen];
    
    
}
-(void)slidescreen {
    float availslide = adscreenview.contentSize.width/curwidth;
    if(repeattime < availslide-1) {
        repeattime = repeattime + 1;
        [adscreenview setContentOffset:CGPointMake(curwidth*repeattime, 0) animated:YES];
    } else {
        repeattime = 0;
        [adscreenview setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    NSLog(@"start slide %f", repeattime);
}

-(void)closescreen {
    NSLog(@"close screen");
    [self.popupController dismissPopupControllerAnimated:YES];
    [autotimer invalidate];
    [slidetimer invalidate];
    slidetimer = nil;
    autotimer = nil;
    [self settimer:@"300.0"];
}

-(IBAction)openview:(id)sender {
    NSLog(@"button has been press");
    
    [self performSegueWithIdentifier:@"popupview" sender:tabbarcontroller];

}
-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"tab view shows");
}
-(void)viewDidDisappear:(BOOL)animated {
    NSLog(@"tab view did disappear");
}
-(void)tabbarinidle {
    NSLog(@"tabbar_log");
    autotimer = nil;
    slidetimer = nil;
}
-(void)tabbarrestart {
    
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
