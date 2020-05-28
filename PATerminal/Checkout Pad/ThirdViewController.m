//
//  ThirdViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "ThirdViewController.h"
#import "ScanViewController.h"
#import "passiveViewController.h"
#import "CNPPopupController.h"
#import "writefiles.h"

@interface ThirdViewController ()<CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation ThirdViewController
@synthesize calcualtvalue, checkoutbutton, showvaluelabel, buttonlabel, onpay, onpaypal, capturesession, videoPreviewLayer, onwechat, onpayment, remarkfield;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"third view");
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDistanceFilter:10.0f];
    [locationManager startUpdatingLocation];
    if([CLLocationManager locationServicesEnabled]) {
        NSLog(@"the location is enabled");
    }else {
        NSLog(@"the location is disable");
    }
    itemsku = [[NSMutableArray alloc] init];
    itemdescription = [[NSMutableArray alloc] init];
    itemimage = [[NSMutableArray alloc] init];
    itemprice = [[NSMutableArray alloc] init];
    itemquantity = [[NSMutableArray alloc] init];
    [self runcd];
    
    cartitemsku = [[NSMutableArray alloc] init];
    cartprice = [[NSMutableArray alloc] init];
    cartquantity = [[NSMutableArray alloc] init];
    cartdescription = [[NSMutableArray alloc] init];
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    
    standarddef = [NSUserDefaults standardUserDefaults];
    countchannel = (int)[[standarddef objectForKey:@"channels"] count];
    
    theqrcodemode = [self->standarddef objectForKey:@"qrcodemode"];
    calcualtvalue = [NSString stringWithFormat:@""];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
                {
                    setcolor = [UIColor blackColor];
                }
                break;
            case 2688:
                {
                    setcolor = [UIColor blackColor];
                }
                break;
            default:
                {
                    setcolor = [UIColor colorWithRed:0.1 green:0.11 blue:0.14 alpha:0.9];
                }
                break;
        }
    }
    
    
    paybutton_width = curwidth/countchannel;
    //paybutton_width = curwidth/3;
    
    uppheigh = curheigh-5*curwidth/4;
    uppheigh_x = curheigh-5*curwidth/4-132;
    uppheight_xr = curheigh-5*curwidth/4-132;
    uppheigh_ipad = curheigh/4;
    NSLog(@"upper height %f", curheigh);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.6 alpha:1]}];
    writefileclass = [[writefiles alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    [self displaypad];
    [self numberpad];
    
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeview:)];
    [rightbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.6 alpha:1], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Check Out"];
    item.rightBarButtonItem = rightbutton;
    item.hidesBackButton = YES;
    self.navigationItem.title = NSLocalizedString(@"Check Out", nil);
    self.navigationItem.rightBarButtonItem = rightbutton;
    /*
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(opencode)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    
    [mainview addGestureRecognizer:swipeGesture];
    */
}
-(void)runcd {
    context = [self managedObjectContext];
    fetchcontext = [self managedObjectModel];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Product_info" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    
    alldata = [context executeFetchRequest:request error:nil];
    
    for (productinfo in alldata) {
        NSLog(@"%@, %@, %@", productinfo.sdk, productinfo.product_description, productinfo.product_id);
        [itemsku addObject:productinfo.sdk];
        [itemdescription addObject:productinfo.product_description];
        [itemprice addObject:productinfo.product_price];
        [itemquantity addObject:productinfo.product_quantity];
        if (productinfo.product_image == NULL) {
            UIImage *imageno = [UIImage imageNamed:@"no_image.png"];
            NSData *imagenodata = UIImagePNGRepresentation(imageno);
            [itemimage addObject:imagenodata];
        } else {
            [itemimage addObject:productinfo.product_image];
        }
        
    }
    //count item of coredata
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    NSLog(@"show count %lu", (unsigned long)count);
    
    NSEntityDescription *entity = [newunit entity];
    NSDictionary *attributes = [entity attributesByName];
    for (NSString *attribute in attributes) {
        id value = [newunit valueForKey:attribute];
        NSLog(@"attribute %@ = %@", attribute, value);
    }
}
-(IBAction)searchcd:(id)sender {
    NSLog(@"%@", sender);
    NSArray *fetchObjects;
    context = [self managedObjectContext];
    fetchcontext = [self managedObjectModel];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entitDescription = [NSEntityDescription entityForName:@"Product_info" inManagedObjectContext:context];
    [fetch setEntity:entitDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ANY sdk contains[cd] %@)", sender]];
    NSError *error = nil;
    fetchObjects = [context executeFetchRequest:fetch error:&error];
    //NSLog(@"show array %@", [fetchObjects objectAtIndex:0]);
    if ([fetchObjects count] != 0) {
        for (productinfo in fetchObjects) {
            scanprice =  productinfo.product_price;
            scanproduct = productinfo.product_description;
        }
        NSAttributedString *scantitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@",scanproduct, scanprice] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSForegroundColorAttributeName : [UIColor blackColor]}];
        [productlabel setAttributedText:scantitle];
        [productlabel setNeedsDisplay];
        [popupbottomview addSubview:productlabel];
        
        double temcaluvalue = [calcualtvalue doubleValue] + [scanprice doubleValue];
        calcualtvalue =  [NSString stringWithFormat:@"%.02f", temcaluvalue];
        NSString *showvalue = [NSString stringWithFormat:@"$ %@", calcualtvalue];
        NSString *showbuttonvalue = [NSString stringWithFormat:@"Total: $ %@", calcualtvalue];
        if ([calcualtvalue length] > 0) {
            onpay.userInteractionEnabled = YES;
        } else {
            onpay.userInteractionEnabled = YES;
        }
        [buttonlabel setText:showbuttonvalue];
        [showvaluelabel setText:showvalue];
        [showvaluelabel setNeedsDisplay];
    } else {
        
    }
    
    [self qrcamfnt];
    //[poptitle setAttributedText:scantitle];
    //[poptitle setNeedsDisplay];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *c = [locations objectAtIndex:0];
    MKCoordinateRegion region;
    CLLocationCoordinate2D setCoord;
    setCoord.latitude = c.coordinate.latitude;
    setCoord.longitude = c.coordinate.longitude;
    region.center = setCoord;
    
    [standarddef setObject:[NSString stringWithFormat:@"%f+%f", region.center.latitude, region.center.longitude] forKey:@"updatelocation"];
}

-(void)displaypad {
    [showvaluelabel removeFromSuperview];
    upperview = [[UIView alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        upperview.frame = CGRectMake(0, 70, curwidth, uppheigh_ipad);
    }else {
        if (curheigh == 812) {
            upperview.frame = CGRectMake(0, 132, curwidth, uppheigh_x);
        } else if (curheigh == 667.00) {
            upperview.frame = CGRectMake(0, 64, curwidth, uppheigh);
        } else if (curheigh == 736.000000) {
            upperview.frame = CGRectMake(0, 64, curwidth, uppheigh);
        } else if (curheigh == 896.000000) {
            upperview.frame = CGRectMake(0, 132, curwidth, uppheight_xr);
        } else if (curheigh == 568.000000) {
            upperview.frame = CGRectMake(0, 64, curwidth, 100);
        }else {
            upperview.frame = CGRectMake(0, 64, curwidth, uppheigh);
        }
    }
    NSLog(@"show the screen %f", upperview.frame.size.height);
    
    [upperview setBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = upperview.frame;
    gradient.colors = @[(id)[UIColor colorWithRed:0.44 green:0.69 blue:0.71 alpha:0.80].CGColor, (id)[UIColor colorWithRed:0.29 green:0.53 blue:0.65 alpha:0.9].CGColor];
    [upperview.layer insertSublayer:gradient atIndex:0];
    */
    
    //upperview.backgroundColor = [UIColor colorWithRed:0.36 green:0.63 blue:0.68 alpha:0.8];
    //buttonlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-30, 20)];
    //buttonlabel.text = [NSString stringWithFormat:@"TOTAL $0"];
    //buttonlabel.textColor = [UIColor whiteColor];
    //buttonlabel.textAlignment = NSTextAlignmentCenter;
    //checkoutbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    //checkoutbutton.frame = CGRectMake(5, 60, curwidth-10, 40);
    //checkoutbutton.backgroundColor = [UIColor colorWithRed:0.3 green:0.5 blue:0.82 alpha:0.8];
    //[checkoutbutton addTarget:self action:@selector(tonextpage:) forControlEvents:UIControlEventTouchUpInside];
    //checkoutbutton.layer.cornerRadius = 10;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        showvaluelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-55, upperview.frame.size.height-30)];
        showvaluelabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:upperview.frame.size.height-35];
    } else {
        if (curheigh == 568.000000) {
            showvaluelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-55, 70)];
            showvaluelabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:68];
        } else {
            showvaluelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-55, 80)];
            showvaluelabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:78];
        }
        
    }
    
    showvaluelabel.textAlignment = NSTextAlignmentRight;
    showvaluelabel.textColor = [UIColor colorWithWhite:0 alpha:1];
    
    showvaluelabel.text = [[NSString stringWithFormat:@"0.00"] uppercaseString];
    showvaluelabel.adjustsFontSizeToFitWidth = YES;
    showvaluelabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    //showvaluelabel.font = [UIFont systemFontOfSize:72 weight:UIFontWeightLight];
    //[checkoutbutton addSubview:buttonlabel];
    UILabel *currency = [[UILabel alloc] initWithFrame:CGRectMake(curwidth-40, 5, 35, 17)];
    currency.text = @"HKD";
    currency.textColor = [UIColor colorWithWhite:0 alpha:1];
    currency.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    currency.textAlignment = NSTextAlignmentLeft;
    
    billremake = [[UILabel alloc] initWithFrame:CGRectMake(50, upperview.frame.size.height-27, curwidth/2-60, 17)];
    billremake.font = [UIFont systemFontOfSize:17 weight:UIFontWeightThin];
    billremake.text = @"Notes";
    billremake.textAlignment = NSTextAlignmentLeft;
    billremake.textColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    
    UIImage *noteimg = [UIImage imageNamed:@"comment_plus"];
    UIButton *notebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    notebutton.frame = CGRectMake(15, upperview.frame.size.height-29, 24, 24);
    [notebutton setImage:noteimg forState:UIControlStateNormal];
    [notebutton addTarget:self action:@selector(opennote) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:upperview];
    [upperview addSubview:checkoutbutton];
    [upperview addSubview:showvaluelabel];
    [upperview addSubview:billremake];
    [upperview addSubview:notebutton];
    [upperview addSubview:currency];
}
-(void)numberpad {
    NSLog(@"numberpad");
    
    NSLog(@"the current width and height %f, %f", curwidth, curheigh);
    
    mainview = [[UIView alloc] init];
    muiltview = [[UIScrollView alloc] init];
    bottomview = [[UIView alloc] init];
    
    tableview = [[UITableView alloc] init];
    tableview.delegate = self;
    tableview.dataSource = self;
    muiltview.delegate = self;
    
    [muiltview setPagingEnabled:YES];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        muiltview.frame = CGRectMake(0, 64+uppheigh_ipad, curwidth, 4*(self.view.frame.size.height-uppheigh_ipad-64)/5);
        mainview.frame = CGRectMake(0, 0, curwidth, muiltview.frame.size.height);
        tableview.frame = CGRectMake(curwidth, 0, curwidth, muiltview.frame.size.height);
        muiltview.contentSize = CGSizeMake(curwidth, 4*(self.view.frame.size.height-uppheigh_ipad-64)/5);
        bottomview.frame = CGRectMake(0, self.view.frame.size.height-(self.view.frame.size.height-uppheigh_ipad-64)/5, curwidth, (self.view.frame.size.height-uppheigh_ipad-64)/5);
    }else {
        if(curheigh == 480.000000) {
            muiltview.frame = CGRectMake(0, 64+uppheigh, curwidth, 4*(curheigh-uppheigh-64)/5);
            mainview.frame = CGRectMake(0, 0, curwidth, muiltview.frame.size.height);
            tableview.frame = CGRectMake(curwidth, 0, curwidth, muiltview.frame.size.height);
            muiltview.contentSize = CGSizeMake(curwidth, 4*(curheigh-uppheigh-64)/5);
            bottomview.frame = CGRectMake(0, (4/5)*(-uppheigh+curheigh-64)+uppheigh+64, curwidth,(curheigh-uppheigh-64)/5);
        } else if (curheigh == 812.000000) {
            muiltview.frame = CGRectMake(0, curheigh-5*curwidth/4, curwidth, 4*(5*curwidth/4)/5);
            mainview.frame = CGRectMake(0, 0, curwidth, muiltview.frame.size.height);
            tableview.frame = CGRectMake(curwidth, 0, curwidth, muiltview.frame.size.height);
            muiltview.contentSize = CGSizeMake(curwidth, 4*(5*curwidth/4)/5);
            bottomview.frame = CGRectMake(0, curheigh-curwidth/4, curwidth, (5*curwidth/4)/5);
        } else {
            muiltview.frame = CGRectMake(0, curheigh-5*curwidth/4, curwidth, 4*(5*curwidth/4)/5);
            mainview.frame = CGRectMake(0, 0, curwidth, muiltview.frame.size.height);
            tableview.frame = CGRectMake(curwidth, 0, curwidth, muiltview.frame.size.height);
            muiltview.contentSize = CGSizeMake(curwidth, 4*(5*curwidth/4)/5);
            bottomview.frame = CGRectMake(0, curheigh-curwidth/4, curwidth, (5*curwidth/4)/5);
        }
    }
    mainview.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    muiltview.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    tableview.backgroundColor = [UIColor whiteColor];
    bottomview.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    
    buttonheigh = mainview.frame.size.height/4;
    //buttonheigh = uppheigh*2/4;
    UIButton *onone = [UIButton buttonWithType:UIButtonTypeCustom];
    onone.frame = CGRectMake(0, 0, curwidth/3, buttonheigh);
    onone.backgroundColor = setcolor;
    [onone setTitle:@"1" forState:UIControlStateNormal];
    onone.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onone setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    onone.tag = 1;
    [onone addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onone.layer.borderWidth = 0.5f;
    onone.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    //CAGradientLayer *gradient = [CAGradientLayer layer];
    //gradient.frame = onone.layer.bounds;
    
    //gradient.colors = [NSArray arrayWithObjects:
    //                   (id)[UIColor colorWithWhite:0.4f alpha:0.5f].CGColor,
    //                   (id)[UIColor colorWithWhite:0.0f alpha:0.7f].CGColor,
    //                   nil];
    //gradient.locations = [NSArray arrayWithObjects:
    //                      [NSNumber numberWithFloat:0.0f],
    //                      [NSNumber numberWithFloat:0.5f],
    //                      nil];
    
    //[onone.layer addSublayer:gradient];
    
    UIButton *ontwo = [UIButton buttonWithType:UIButtonTypeCustom];
    ontwo.frame = CGRectMake(curwidth/3, 0, curwidth/3, buttonheigh);
    ontwo.backgroundColor = setcolor;
    [ontwo setTitle:@"2" forState:UIControlStateNormal];
    ontwo.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [ontwo setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [ontwo setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    ontwo.tag = 2;
    [ontwo addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    ontwo.layer.borderWidth = 0.5f;
    ontwo.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onthree = [UIButton buttonWithType:UIButtonTypeCustom];
    onthree.frame =CGRectMake(curwidth/3*2, 0, curwidth/3, buttonheigh);
    onthree.backgroundColor = setcolor;
    onthree.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onthree setTitle:@"3" forState:UIControlStateNormal];
    [onthree setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onthree setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onthree.tag = 3;
    [onthree addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onthree.layer.borderWidth = 0.5f;
    onthree.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onfour = [UIButton buttonWithType:UIButtonTypeCustom];
    onfour.frame = CGRectMake(0, buttonheigh, curwidth/3, buttonheigh);
    onfour.backgroundColor = setcolor;
    [onfour setTitle:@"4" forState:UIControlStateNormal];
    onfour.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onfour setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onfour setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onfour.tag = 4;
    [onfour addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onfour.layer.borderWidth = 0.5f;
    onfour.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onfive = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3, buttonheigh, curwidth/3, buttonheigh)];
    onfive.backgroundColor = setcolor;
    [onfive setTitle:@"5" forState:UIControlStateNormal];
    onfive.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onfive setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onfive setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onfive.tag = 5;
    [onfive addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onfive.layer.borderWidth = 0.5f;
    onfive.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onsix = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3*2, buttonheigh, curwidth/3, buttonheigh)];
    onsix.backgroundColor = setcolor;
    onsix.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onsix setTitle:@"6" forState:UIControlStateNormal];
    [onsix setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onsix setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onsix.tag = 6;
    [onsix addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onsix.layer.borderWidth = 0.5f;
    onsix.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onsev = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonheigh*2, curwidth/3, buttonheigh)];
    onsev.backgroundColor = setcolor;
    [onsev setTitle:@"7" forState:UIControlStateNormal];
    onsev.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onsev setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onsev setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onsev.tag = 7;
    [onsev addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onsev.layer.borderWidth = 0.5f;
    onsev.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *oneig = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3, buttonheigh*2, curwidth/3, buttonheigh)];
    oneig.backgroundColor = setcolor;
    [oneig setTitle:@"8" forState:UIControlStateNormal];
    oneig.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [oneig setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [oneig setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    oneig.tag = 8;
    [oneig addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    oneig.layer.borderWidth = 0.5f;
    oneig.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onnin = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3*2, buttonheigh*2, curwidth/3, buttonheigh)];
    onnin.backgroundColor = setcolor;
    [onnin setTitle:@"9" forState:UIControlStateNormal];
    onnin.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onnin setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onnin setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onnin.tag = 9;
    [onnin addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onnin.layer.borderWidth = 0.5f;
    onnin.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *oncen = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonheigh*3, curwidth/3, buttonheigh)];
    oncen.backgroundColor = [UIColor colorWithRed:0.91 green:0.59 blue:0.21 alpha:0.8];
    //[oncen setTitle:@"c" forState:UIControlStateNormal];
    //oncen.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [oncen setImage:[UIImage imageNamed:@"buttonback"] forState:UIControlStateNormal];
    [oncen setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [oncen setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [oncen addTarget:self action:@selector(cancelno:) forControlEvents:UIControlEventTouchUpInside];
    oncen.layer.borderWidth = 0.5f;
    oncen.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onzero = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3, buttonheigh*3, curwidth/3, buttonheigh)];
    onzero.backgroundColor = setcolor;
    [onzero setTitle:@"0" forState:UIControlStateNormal];
    onzero.titleLabel.font = [UIFont fontWithName:@"Signika-Regular" size:28];
    [onzero setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [onzero setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onzero.tag = 0;
    [onzero addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onzero.layer.borderWidth = 0.5f;
    onzero.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UIButton *onextra = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/3*2, buttonheigh*3, curwidth/3, buttonheigh)];
    onextra.backgroundColor = setcolor;
    [onextra setTitle:@"." forState:UIControlStateNormal];
    onextra.titleLabel.font =[UIFont fontWithName:@"Signika-Regular" size:28];
    [onextra setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onextra setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    onextra.tag = 10;
    [onextra addTarget:self action:@selector(numpadpress:) forControlEvents:UIControlEventTouchUpInside];
    onextra.layer.borderWidth = 0.5f;
    onextra.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    
    [muiltview addSubview:mainview];
    //[muiltview addSubview:tableview];
    [self.view addSubview:muiltview];
    [self.view addSubview:bottomview];
    [self paywithpayment];
    
    
    [mainview addSubview:onone];
    [mainview addSubview:ontwo];
    [mainview addSubview:onthree];
    [mainview addSubview:onfour];
    [mainview addSubview:onfive];
    [mainview addSubview:onsix];
    [mainview addSubview:onsev];
    [mainview addSubview:oneig];
    [mainview addSubview:onnin];
    [mainview addSubview:oncen];
    [mainview addSubview:onzero];
    [mainview addSubview:onextra];
    
    //[onpay addSubview:alipayicon];
}
-(void)paywithpayment {
    onpayment = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, curwidth, bottomview.frame.size.height)];
    onpayment.backgroundColor = [UIColor colorWithRed:0.22 green:0.62 blue:0.91 alpha:1];
    [onpayment setTitle:@"" forState:UIControlStateNormal];
    [onpayment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onpayment setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [onpayment addTarget:self action:@selector(tonextpage:) forControlEvents:UIControlEventTouchUpInside];
    //[onpayment addTarget:self action:@selector(tomethod:) forControlEvents:UIControlEventTouchUpInside];
    onpayment.layer.borderWidth = 0.5f;
    onpayment.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    UILabel *alipaylabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, bottomview.frame.size.height-20)];
    alipaylabel.text = NSLocalizedString(@"Charge", nil);
    alipaylabel.textAlignment = NSTextAlignmentCenter;
    alipaylabel.textColor = [UIColor whiteColor];
    alipaylabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:31];
    alipaylabel.adjustsFontSizeToFitWidth = YES;
    
    [onpayment addSubview:alipaylabel];
    [bottomview addSubview:onpayment];
}
-(IBAction)paywithAlipay:(id)sender {
    onpay = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomview.frame.size.height*[sender intValue], curwidth, bottomview.frame.size.height)];
    onpay.backgroundColor = [UIColor colorWithRed:0.22 green:0.62 blue:0.91 alpha:1];
    [onpay setTitle:@"" forState:UIControlStateNormal];
    [onpay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onpay setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //[onpay addTarget:self action:@selector(tonextpage:) forControlEvents:UIControlEventTouchUpInside];
    [onpay addTarget:self action:@selector(tonextpage:) forControlEvents:UIControlEventTouchUpInside];
    onpay.layer.borderWidth = 0.5f;
    onpay.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    UILabel *alipaylabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, bottomview.frame.size.height-20)];
    alipaylabel.text = NSLocalizedString(@"Alipay", nil);
    alipaylabel.textAlignment = NSTextAlignmentCenter;
    alipaylabel.textColor = [UIColor whiteColor];
    alipaylabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:31];
    alipaylabel.adjustsFontSizeToFitWidth = YES;
    
    [onpay addSubview:alipaylabel];
    [popcontentview addSubview:onpay];
}
-(IBAction)paywithpaypal:(id)sender {
    onpaypal = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomview.frame.size.height*[sender intValue], curwidth, bottomview.frame.size.height)];
    onpaypal.backgroundColor = [UIColor colorWithRed:0.13 green:0.44 blue:0.73 alpha:1];
    [onpaypal setTitle:@"" forState:UIControlStateNormal];
    [onpaypal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onpaypal setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [onpaypal addTarget:self action:@selector(topassive:) forControlEvents:UIControlEventTouchUpInside];
    onpaypal.layer.borderWidth = 0.5f;
    onpaypal.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UILabel *paypallabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, bottomview.frame.size.height-20)];
    paypallabel.text = NSLocalizedString(@"PayPal", nil);
    paypallabel.textAlignment = NSTextAlignmentCenter;
    paypallabel.textColor = [UIColor whiteColor];
    paypallabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:31];
    paypallabel.adjustsFontSizeToFitWidth = YES;
    
    [onpaypal addSubview:paypallabel];
    [popcontentview addSubview:onpaypal];
}
-(void)paywithwechat {
    onwechat = [[UIButton alloc] initWithFrame:CGRectMake(curwidth/2, 0, paybutton_width, bottomview.frame.size.height)];
    onwechat.backgroundColor = [UIColor colorWithRed:0.37 green:0.79 blue:0.20 alpha:1];
    [onwechat setTitle:@"" forState:UIControlStateNormal];
    [onwechat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [onwechat setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [onwechat addTarget:self action:@selector(tonextpage:) forControlEvents:UIControlEventTouchUpInside];
    onwechat.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    UILabel *wechatlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, paybutton_width-20, bottomview.frame.size.height-20)];
    wechatlabel.text = NSLocalizedString(@"WeChat", nil);
    wechatlabel.textAlignment = NSTextAlignmentCenter;
    wechatlabel.textColor = [UIColor whiteColor];
    wechatlabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:31];
    wechatlabel.adjustsFontSizeToFitWidth = YES;
    [onwechat addSubview:wechatlabel];
    [popcontentview addSubview:onwechat];
}
-(void)opencode {
    [self showPopupWithStyle:CNPPopupStyleActionSheet];
}
-(void)openmethod {
    [self showPopupwithStyle1:CNPPopupStyleActionSheet];
}
-(void)showPopupwithStyle1:(CNPPopupStyle)popupStyle {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Choose Type" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    
    poptopview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    poptopview.backgroundColor = [UIColor whiteColor];
    
    popcontentview = [[UIView alloc] initWithFrame:CGRectMake(0, 60, curwidth, bottomview.frame.size.height*countchannel)];
    popcontentview.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    
    CALayer *bottomborder = [CALayer layer];
    bottomborder.frame = CGRectMake(0.0f, 59.0f, curwidth, 1);
    bottomborder.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.8].CGColor;
    [poptopview.layer addSublayer:bottomborder];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(curwidth-60, 0, 60, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"x" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6];
    button.layer.cornerRadius = 0;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    
    UILabel *popuptitle = [[UILabel alloc] init];
    popuptitle.frame = CGRectMake(0, 0, curwidth, 60);
    popuptitle.numberOfLines = 0;
    popuptitle.attributedText = title;
    
    for (int i=0; i<countchannel; i++) {
        if([[[standarddef objectForKey:@"channels"] objectAtIndex:i] isEqualToString:@"ALIPAYOFFLINE"]) {
            [self performSelector:@selector(paywithAlipay:) withObject:[NSString stringWithFormat:@"%d", i] afterDelay:0];
        } else if ([[[standarddef objectForKey:@"channels"] objectAtIndex:i] isEqualToString:@"PAYPAL"]) {
            [self performSelector:@selector(paywithpaypal:) withObject:[NSString stringWithFormat:@"%d", i] afterDelay:0];
        }
    }
    [poptopview addSubview:popuptitle];
    [poptopview addSubview:button];
    self.popupController = [[CNPPopupController alloc] initWithContents:@[poptopview, popcontentview]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}
- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Scan Code" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    topview.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    
    popupbottomview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    popupbottomview.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(curwidth-60, 0, 60, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"x" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6];
    button.layer.cornerRadius = 0;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    poptitle = [[UILabel alloc] init];
    poptitle.frame = CGRectMake(0, 0, curwidth, 60);
    poptitle.numberOfLines = 0;
    poptitle.attributedText = title;
    
    customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curwidth-60)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    productlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    productlabel.textAlignment = NSTextAlignmentCenter;
    
    [self qrcamfnt];
    [customView addSubview:scanView];
    [topview addSubview:button];
    [topview addSubview:poptitle];
    [popupbottomview addSubview:productlabel];
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[topview, customView, popupbottomview]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

-(void)showPopupWithtext:(CNPPopupStyle)popupStyle {
    NSLog(@"test");
    
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, 88, curwidth, curheigh)];
    topview.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    UILabel *toplabel = [[UILabel alloc] init];
    toplabel.frame = CGRectMake(0, 44, curwidth, 32);
    toplabel.text = @"Add Note";
    toplabel.textAlignment = NSTextAlignmentCenter;
    toplabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightMedium];
    toplabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    
    remarkfield = [[UITextField alloc] init];
    remarkfield.delegate = self;
    remarkfield.frame = CGRectMake(10, curheigh/2-36, curwidth-20, 36);
    remarkfield.placeholder = @"Remark...";
//    [remarkfield setBorderStyle:UITextBorderStyleLine];
    remarkfield.layer.masksToBounds = true;
    CALayer *border1 = [CALayer layer];
    
    UIButton *donebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    donebutton.frame = CGRectMake(10, curheigh/2+5, curwidth-20, 36);
//    donebutton.titleLabel.text = @"Done";
    
    [donebutton setTitle:@"Done" forState:UIControlStateNormal];
    [donebutton setTitleColor:[UIColor colorWithRed:0.35 green:0.42 blue:0.85 alpha:1] forState:UIControlStateNormal];
    [donebutton addTarget:self action:@selector(regmark:) forControlEvents:UIControlEventTouchUpInside];
    border1.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor;
    border1.frame = CGRectMake(0, remarkfield.frame.size.height - 1, remarkfield.frame.size.width, remarkfield.frame.size.height);
    border1.borderWidth = 1;
    [remarkfield.layer addSublayer:border1];
    
    
    [topview addSubview:toplabel];
    [topview addSubview:remarkfield];
    [topview addSubview:donebutton];
    self.popupController = [[CNPPopupController alloc] initWithContents:@[topview]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

-(void)qrcamfnt {
    NSLog(@"run qr");
    //turn on the qr camera
    _isReading = NO;
    capturesession = nil;
    scanView = [[UIImageView alloc] init];
    scanView.frame = CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height);
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (videoDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            capturesession = [[AVCaptureSession alloc]init];
            if ([capturesession canAddInput:videoInput]) {
                [capturesession addInput:videoInput];
                AVCaptureMetadataOutput *catureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
                [capturesession addOutput:catureMetadataOutput];
                
                dispatch_queue_t dispatchQueue;
                dispatchQueue = dispatch_queue_create("myQueue", NULL);
                [catureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
                [catureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeCode39Mod43Code, nil]];
                videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:capturesession];
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                videoPreviewLayer.frame = scanView.bounds;
                [scanView.layer addSublayer:videoPreviewLayer];
                [capturesession startRunning];
            }
        }
    }
    //end of QR cam
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //NSLog(@"the code %@", [metadataObj stringValue]);
        scanqrcode = [metadataObj stringValue];
        [self performSelectorOnMainThread:@selector(searchcd:) withObject:scanqrcode waitUntilDone:YES];
        
        [capturesession stopRunning];
    }
}
-(void)stopReading {
    capturesession = nil;
    //[standarddefault setObject:scanqrcode forKey:@"add_sku"];
    dispatch_async(dispatch_get_main_queue(), ^{
    
    });
    
}
-(void)viewDidAppear:(BOOL)animated {
    calcualtvalue = @"";
    onpay.userInteractionEnabled = NO;
    writefileclass.updatelocation = [standarddef objectForKey:@"updatelocation"];
    [writefileclass setpageview:@"keypad.view"];
}
-(void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:NO];
}
-(void)viewDidDisappear:(BOOL)animated {
    [showvaluelabel setText:@"$0"];
}
-(IBAction)numpadpress:(id)sender {
    UIButton *cliecked = (UIButton *) sender;
    int recallvalue = (int)cliecked.tag;
    NSString *finalvalue = [NSString stringWithFormat:@"%ld", (long)recallvalue];
    if(recallvalue == 10) {
        finalvalue = @".";
    }
    
    calcualtvalue = [NSString stringWithFormat:@"%@%@", calcualtvalue, finalvalue];
    
    NSLog(@"show value %@ %@", finalvalue, calcualtvalue);
    if ([calcualtvalue hasPrefix:@"."] || [calcualtvalue hasPrefix:@"0"]) {
        calcualtvalue = [calcualtvalue substringFromIndex:1];
    }
    NSArray *truevalue = [calcualtvalue componentsSeparatedByString:@"."];
    if([truevalue count] > 2) {
        NSLog(@"have dot");
        calcualtvalue = [calcualtvalue substringToIndex:[calcualtvalue length]-1];
    } else if ([truevalue count] == 2 && [truevalue[1] length]> 2){
        calcualtvalue = [calcualtvalue substringToIndex:[calcualtvalue length]-1];
    }   else {
        NSLog(@"no dot");
    }
    if ([calcualtvalue length] > 7 || [calcualtvalue floatValue] > 99999.99) {
        calcualtvalue = @"99999.99";
    }
    NSLog(@"no pad is press %@", calcualtvalue);
    NSString *showvalue = [NSString stringWithFormat:@"$ %@", calcualtvalue];
    NSString *showbuttonvalue = [NSString stringWithFormat:@"Total: $ %@", calcualtvalue];
    if ([calcualtvalue length] > 0) {
        onpay.userInteractionEnabled = YES;
    } else {
        onpay.userInteractionEnabled = YES;
    }
//    if ([calcualtvalue length] == 0 && recallvalue == 0) {
//        showvalue = @"0.00";
//    }
//    if([calcualtvalue length] == 0 && [finalvalue isEqualToString:@"."]) {
//        NSLog(@"show the dot");
//        showvalue = @"0.";
//    }
    
    [buttonlabel setText:showbuttonvalue];
    [showvaluelabel setText:showvalue];
    [showvaluelabel setNeedsDisplay];
}
-(IBAction)cancelno:(id)sender {
    if([calcualtvalue length] > 0) {
        calcualtvalue = [calcualtvalue substringToIndex:[calcualtvalue length]-1];
        NSString *showvalue = [NSString stringWithFormat:@"$ %@", calcualtvalue];
        [showvaluelabel setText:showvalue];
        [buttonlabel setText:calcualtvalue];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)tonextpage:(id)sender {
    NSLog(@"to next page action");
    if ([calcualtvalue length] > 0 && [calcualtvalue integerValue] != 0) {
        NSLog(@"next page");
        [self.popupController dismissPopupControllerAnimated:YES];
        scanview = [self.storyboard instantiateViewControllerWithIdentifier:@"scanview"];
        scanview.chargingvalue = calcualtvalue;
        [self.navigationController pushViewController:scanview animated:YES];
        //[self presentViewController:scanview animated:YES completion:nil];
    } else {
        [self errormsg];
    }
    
}
-(IBAction)tomethod:(id)sender {
    [self showPopupwithStyle1:CNPPopupStyleActionSheet];
}
-(IBAction)topassive:(id)sender {
    //passiveview
    if([calcualtvalue length] > 0 && [calcualtvalue integerValue] != 0) {
        NSLog(@"next page");
        [self.popupController dismissPopupControllerAnimated:YES];
        passiveview = [self.storyboard instantiateViewControllerWithIdentifier:@"passiveview"];
        passiveview.stringvalue = calcualtvalue;
        [self.navigationController pushViewController:passiveview animated:YES];
    }else {
        [self errormsg];
    }
}
-(void)cMethod {
    NSUserDefaults *standarduser = [NSUserDefaults standardUserDefaults];
    [standarduser removeObjectForKey:@"users"];
    
}
-(void)errormsg {
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Amount input" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:ok];
    [self presentViewController:alertcontroller animated:YES completion:nil];
}

-(IBAction)closeview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = (NSUInteger)(muiltview.contentOffset.x / muiltview.bounds.size.width) + 1;
    NSLog(@"show page %lu", (unsigned long)page);
    if(scrollView == tableview) {
        NSLog(@"it is a tableview");
    }else {
        calcualtvalue = [NSString stringWithFormat:@""];
        NSString *showvalue = [NSString stringWithFormat:@"$ %ld", (long)[calcualtvalue integerValue]];
        NSString *showbuttonvalue = [NSString stringWithFormat:@"Total: $ %@", calcualtvalue];
        if ([calcualtvalue length] > 0) {
            onpay.userInteractionEnabled = YES;
        } else {
            onpay.userInteractionEnabled = YES;
        }
        [buttonlabel setText:showbuttonvalue];
        [showvaluelabel setText:showvalue];
        [showvaluelabel setNeedsDisplay];
    }
}
#pragma mark Table view methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [alldata count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [itemdescription objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"SKU: %@", [itemsku objectAtIndex:indexPath.row]];
    [cell.imageView setImage:[UIImage imageWithData:[itemimage objectAtIndex:indexPath.row]]];
    
    UILabel *productprice = [[UILabel alloc] initWithFrame:CGRectMake(2*curwidth/3, 10, curwidth/3, 40)];
    productprice.text = [NSString stringWithFormat:@"HKD %@",  [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[[itemprice objectAtIndex:indexPath.row] doubleValue]]]];
    productprice.font = [UIFont systemFontOfSize:23];
    productprice.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:productprice];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [cartitemsku addObject:[itemsku objectAtIndex:indexPath.row]];
    [cartprice addObject:[itemprice objectAtIndex:indexPath.row]];
    [cartquantity addObject:[itemquantity objectAtIndex:indexPath.row]];
    [cartdescription addObject:[itemdescription objectAtIndex:indexPath.row]];
    double temcaluvalue = [calcualtvalue doubleValue] + [[itemprice objectAtIndex:indexPath.row] doubleValue];
    calcualtvalue =  [NSString stringWithFormat:@"%.02f", temcaluvalue];
    NSString *showvalue = [NSString stringWithFormat:@"$ %@", calcualtvalue];
    NSString *showbuttonvalue = [NSString stringWithFormat:@"Total: $ %@", calcualtvalue];
    if ([calcualtvalue length] > 0) {
        onpay.userInteractionEnabled = YES;
    } else {
        onpay.userInteractionEnabled = YES;
    }
    [buttonlabel setText:showbuttonvalue];
    [showvaluelabel setText:showvalue];
    [showvaluelabel setNeedsDisplay];
    NSLog(@"show array %@", cartdescription);
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.altawoz.testtable" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MainModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MainModel.sqlite"];
    NSPersistentStore *store = [_persistentStoreCoordinator persistentStoreForURL:storeURL];
    
    NSError *error = nil;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    /*
     NSUserDefaults *standarddefault = [NSUserDefaults standardUserDefaults];
     if (version != [standarddefault objectForKey:@"bundlestring"]) {
     [standarddefault setObject:version forKey:@"bundlestring"];
     [standarddefault setObject:@"0" forKey:@"lastDinputvalue"];
     [standarddefault removeObjectForKey:@"firstdatadump"];
     [standarddefault removeObjectForKey:@"lastinputvalue"];
     [_persistentStoreCoordinator removePersistentStore:store error:nil];
     [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
     } else {
     NSLog(@"bundle %@", [standarddefault objectForKey:@"bundlestring"]);
     
     }
     */
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        
        NSLog(@"things success");
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

-(void)opennote{
    NSLog(@"open note");
    [self showPopupWithtext:CNPPopupStyleActionSheet];
}
-(IBAction)regmark:(id)sender {
    if(remarkfield.text.length > 0) {
        [standarddef setObject:remarkfield.text forKey:@"transaction_remark"];
        billremake.text = remarkfield.text;
        [billremake setNeedsDisplay];
    }
    [self.popupController dismissPopupControllerAnimated:YES];
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
