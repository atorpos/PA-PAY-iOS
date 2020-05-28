//
//  FirstViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "FirstViewController.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
//#import <PAPAY_FW/PAPAY_FW.h>
#import "SBJson5.h"
#import "writefiles.h"
#import "setimer.h"
#import "LoginViewController.h"
#import "PromotionViewController.h"
#import "CNPPopupController.h"
#import <Security/Security.h>
#import "AESCrypt.h"
#import "papay_frameworks.h"
#import "services.pch"
#import <StoreKit/StoreKit.h>

@interface FirstViewController () <CLLocationManagerDelegate, CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pafw = [[papay_frameworks alloc] init];
    pafw.loginid = @"what is wrong";
    
    [pafw login];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    //[subclass openurl];
    //prove of framework sha512
    //NSLog(@"test sha 512 %@", [subclass performSelector:@selector(createSHA512:) withObject:@"123456"]);
    
    
    standardUser = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"counting %@", [standardUser objectForKey:@"usetime"]);
    
    if([[standardUser objectForKey:@"usetime"] intValue] == 6) {
        [SKStoreReviewController requestReview];
    }
    NSString *stringskd = [NSString stringWithFormat:@""];
    for (int i =0; i<15; i++) {
        NSString *gennum = [NSString stringWithFormat:@"%d", arc4random() %10];
        stringskd = [NSString stringWithFormat:@"%@%@",stringskd,gennum];
    }
    //NSString *encystring = [NSString stringWithFormat:@"%@", [AESCrypt encryptvi:@"123456" password:@"123ABC12"]];
    
    //NSData *nsdata = [encystring dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    //NSLog(@"log record %@, %@", encystring, stringskd);
    
    // Do any additional setup after loading the view, typically from a nib.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    UIImageView *titleimg = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, curwidth-80, 30)];
    //titleimg.backgroundColor = [UIColor clearColor];
    UIImage *titlelogo = [UIImage imageNamed:@"OpeningPG_logo.png"];
    titleimg.contentMode = UIViewContentModeScaleAspectFit;
    [titleimg setImage:titlelogo];
    self.navigationItem.titleView = titleimg;
    transitionquery = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL,INFORMATION_ENDPOINT];
    NSLog(@"app data: The screen size %f, %f, token %@, language %@, qrcode %@, imgurl %@ ", curwidth, curheigh, [standardUser objectForKey:@"signtoken"], [standardUser objectForKey:@"systemlanguage"], [standardUser objectForKey:@"qrcodestring"], [standardUser objectForKey:@"ad_screensaver"]);
    
    shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.paymentasia.papay"];
    [shared setObject:[standardUser objectForKey:@"qrcodestring"] forKey:@"qrcodestring"];
    [shared synchronize];
//    [self imagetosave];
    //[self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.49 green:0.48 blue:0.67 alpha:0.8]];
    //[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    // Create a dispatch source that'll act as a timer on the concurrent queue
    // You'll need to store this somewhere so you can suspend and remove it later on
    
    if ([[standardUser objectForKey:@"ad_screensaver"] count] > 0) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("My Queue", NULL);
        
        dispatch_async(downloadQueue, ^{
            for (int i = 0; i < [[self->standardUser objectForKey:@"ad_screensaver"] count]; i++) {
                [self downloadfile:[[self->standardUser objectForKey:@"ad_screensaver"] objectAtIndex:i]];
            }
        });
    }
    //[PAPass performSelector:@selector(sentrequest:) withObject:@"123" afterDelay:0];
    UIImageView *bgimgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    UIImage *bgimg = [UIImage imageNamed:@"fristpagebg.png"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:bgimg.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius"];
    CIImage *result =[filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *outputimg = [UIImage imageWithCGImage:cgImage];
    
    bgimgview.contentMode = UIViewContentModeScaleAspectFill;
    bgimgview.clipsToBounds = YES;
    [bgimgview setImage:outputimg];
    
    //[self.view addSubview:bgimgview];
    firstpanel = [[UIView alloc] init];
    secpanel = [[UIView alloc] init];
    thipanel = [[UIView alloc] init];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        firstpanel.frame = CGRectMake(0, 64, curwidth, curheigh/4);
        secpanel.frame = CGRectMake(0,curheigh/3.5+curwidth/6+10, curwidth, curheigh/3+60);
        //thipanel.frame = CGRectMake(0, 0.619048*curheigh+curwidth/6+10, curwidth, 0.380952*curheigh-curwidth/6-10);
    } else {
        if (curheigh == 812.00) {
            firstpanel.frame = CGRectMake(0, 89, curwidth, curheigh/4);
            secpanel.frame = CGRectMake(0,curheigh/4+89, curwidth, curheigh/3+60);
        } else if(curheigh == 667.00) {
            firstpanel.frame = CGRectMake(0, curwidth/6+2, curwidth, curheigh/4);
            secpanel.frame = CGRectMake(0,curheigh/4+curwidth/6+2, curwidth, curheigh/3+60);
           
        } else if(curheigh == 736.00){
            firstpanel.frame = CGRectMake(0, curwidth/6-4, curwidth, curheigh/4);
            secpanel.frame = CGRectMake(0,curheigh/4+curwidth/6-4, curwidth, curheigh/3+60);
        } else {
            firstpanel.frame = CGRectMake(0, curwidth/6+10, curwidth, curheigh/3.5);
            secpanel.frame = CGRectMake(0,curheigh/3.5+curwidth/6+10, curwidth, curheigh/3+60);
        }
    }
    
    firstpanel.backgroundColor = [UIColor colorWithRed:0.27 green:0.46 blue:0.66 alpha:1];
    secpanel.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
    
    
    longpressrecg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress:)];
    [longpressrecg setNumberOfTapsRequired:0];
    [longpressrecg setMinimumPressDuration:1.0];
    [longpressrecg setDelegate:self];
    [self.view addGestureRecognizer:longpressrecg];
    [self.view addSubview:firstpanel];
    [self.view addSubview:secpanel];
    [self createinterface];
    
}
- (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'A','A','A','A','A','A'};
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
    
    return md;
}
-(void)downloadfile:(id)sender {
    NSString *urlstring = sender;
    NSArray *listvalue = [urlstring componentsSeparatedByString:@"/"];
    NSString *savefilename = [listvalue lastObject];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,savefilename];
    if ([fileManage fileExistsAtPath:filePath]) {
        NSLog(@"file exist");
    } else {
        NSURL *url = [NSURL URLWithString:urlstring];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        if (urlData) {
            [urlData writeToFile:filePath atomically:YES];
        }
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *c = [locations objectAtIndex:0];
    MKCoordinateRegion region;
    CLLocationCoordinate2D setCoord;
    setCoord.latitude = c.coordinate.latitude;
    setCoord.longitude = c.coordinate.longitude;
    region.center = setCoord;
    
    [standardUser setObject:[NSString stringWithFormat:@"%f+%f", region.center.latitude, region.center.longitude] forKey:@"updatelocation"];
}
-(void)reprintaction:(id)sender {
    NSLog(@"testing timer");
}

-(void)checkinfo{
    NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standardUser objectForKey:@"signtoken"]];
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:transitionquery]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (response &&! error) {
             self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"QR %@", self->readtext);
             if (![self->readtext isEqualToString:@"no value"]) {
                 [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
             } else {
                 NSLog(@"no value");
             }
         } else {
         }
    }];
    
    [task resume];
}

-(void)fetchdata:(NSData *)requestdata {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    if([[[json valueForKey:@"response"] valueForKey:@"code"] integerValue] != 200) {
        [self performSelectorOnMainThread:@selector(cancelallsession:) withObject:nil waitUntilDone:YES];
    } else {
        accountname = [[json valueForKey:@"payload"] valueForKey:@"name"];
        totalamount = [[json valueForKey:@"payload"] valueForKey:@"amount"];
        [shared setObject:totalamount forKey:@"update_amount"];
        [shared synchronize];
        lasttranscation = [[json valueForKey:@"payload"] valueForKey:@"last_transaction_time"];
        [standardUser setObject:[[json valueForKey:@"payload"] valueForKey:@"screen_saver"] forKey:@"ad_screensaver"];
        [self showinfo];
    }
}

-(void)showinfo {
    [maxdollar removeFromSuperview];
    
    maxdollar = [[UILabel alloc] initWithFrame:CGRectMake(80, 40, curwidth-160, 45)];
    maxdollar.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:43];
    maxdollar.textAlignment = NSTextAlignmentCenter;
    maxdollar.adjustsFontSizeToFitWidth = YES;
    maxdollar.textColor =[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    [maxdollar setText:[NSString stringWithFormat:@"%.2f", [totalamount doubleValue]]];
    [secpanel addSubview:maxdollar];
    
}

-(void)createinterface {
    UIImageView *userpic = [[UIImageView alloc] initWithFrame:CGRectMake(curwidth/2-25, (firstpanel.frame.size.height-108)/2, 50, 50)];
    [userpic setImage:[UIImage imageNamed:@"temp_user.png"]];
    userpic.layer.borderWidth = 2.0f;
    userpic.layer.borderColor = [UIColor whiteColor].CGColor;
    userpic.layer.cornerRadius = 25;
    userpic.layer.masksToBounds = YES;
    [firstpanel addSubview:userpic];
    
    clientname = [[UILabel alloc] initWithFrame:CGRectMake(10, (firstpanel.frame.size.height-108)/2+55, curwidth-20, 28)];
    //clientname.text = [NSString stringWithFormat:@"ID: %@", [standardUser objectForKey:@"MerchID"]];
    clientname.textAlignment = NSTextAlignmentCenter;
    clientname.adjustsFontSizeToFitWidth = YES;
    clientname.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:26.0f];
    clientname.textColor = [UIColor whiteColor];
    [clientname setText:[NSString stringWithFormat:@"%@", [standardUser objectForKey:@"merchant_name"]]];
    [firstpanel addSubview:clientname];
    
    terminalidlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (firstpanel.frame.size.height-108)/2+55+33, curwidth-20, 15)];
    terminalidlabel.textColor = [UIColor whiteColor];
    terminalidlabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:13];
    [terminalidlabel setText:[NSString stringWithFormat:NSLocalizedString(@"Terminal: %@", nil),[standardUser objectForKey:@"terminalid"]]];
    terminalidlabel.textAlignment = NSTextAlignmentCenter;
    [firstpanel addSubview:terminalidlabel];
}

-(void)createQR {
    NSString *urlstring = [standardUser objectForKey:@"qrcodestring"];
    NSData *stringData = [urlstring dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter *qrfilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrfilter setValue:stringData forKey:@"inputMessage"];
    [qrfilter setValue:@"L" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCodeImage = qrfilter.outputImage;
    CGRect imagesize = CGRectIntegral(qrCodeImage.extent);
    CGSize outputsize = CGSizeMake(secpanel.frame.size.width, secpanel.frame.size.width);
    CIImage *imageResize = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputsize.width/CGRectGetWidth(imagesize), outputsize.height/CGRectGetHeight(imagesize))];
    
    
    UIImageView *showview = [[UIImageView alloc] initWithFrame:CGRectMake(15, showqrview.frame.size.height/2-(showqrview.frame.size.width-30)/2, showqrview.frame.size.width-30, showqrview.frame.size.width-30)];
    UIImage *imageset = [[UIImage alloc] initWithCIImage:imageResize];
    
//    UIImageView *logoview = [[UIImageView alloc] initWithFrame:CGRectMake(showview.frame.size.width/2-(secpanel.frame.size.width/5-8)*0.5, showview.frame.size.width/2-(secpanel.frame.size.width/5-8)*0.5, secpanel.frame.size.width/5-8, secpanel.frame.size.width/5-8)];
//    UIImage *logoset = [UIImage imageNamed:@"mid_qr_logo.png"];
//    [logoview setImage:logoset];
    [showview setImage:imageset];
    
    UIImageView *comlogoview = [[UIImageView alloc] initWithFrame:CGRectMake(5, secpanel.frame.size.width-20, secpanel.frame.size.width-10, 15)];
    UIImage *comlogo = [UIImage imageNamed:@"pa_logo_1200x180.png"];
    comlogoview.contentMode = UIViewContentModeScaleAspectFill;
    [comlogoview setImage:comlogo];
    
    [showqrview addSubview:showview];
    //[secpanel addSubview:showview];
//    [showview addSubview:logoview];
    //[secpanel addSubview:comlogoview];
}

-(void)createtranscation {
    UILabel *todaylabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, curwidth-20, 17)];
    todaylabel.textAlignment = NSTextAlignmentLeft;
    todaylabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    todaylabel.text  = NSLocalizedString(@"Today's Transcation", nil);
    todaylabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15.0f];
    UILabel *dollarsign = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 20, 17)];
    dollarsign.text = @"$";
    dollarsign.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    dollarsign.textAlignment = NSTextAlignmentRight;
    dollarsign.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    
    UILabel *currencylabel = [[UILabel alloc] initWithFrame:CGRectMake(curwidth-80, 40, 80, 17)];
    currencylabel.text = @"HKD";
    currencylabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    currencylabel.textAlignment = NSTextAlignmentLeft;
    currencylabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    
    UIButton *queryqrcode = [UIButton buttonWithType:UIButtonTypeCustom];
    queryqrcode.frame = CGRectMake(60, secpanel.frame.size.height-140, curwidth-120, 40);
    [queryqrcode setTitle:NSLocalizedString(@"Open QR Code", nil) forState:UIControlStateNormal];
    [queryqrcode setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
    [queryqrcode setBackgroundColor:[UIColor whiteColor]];
    queryqrcode.layer.borderWidth = 0.5f;
    queryqrcode.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    queryqrcode.layer.cornerRadius = 20.0f;
    [queryqrcode setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [queryqrcode addTarget:self action:@selector(showtheqr) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *promobutton = [UIButton buttonWithType:UIButtonTypeCustom];
    promobutton.frame = CGRectMake(60, secpanel.frame.size.height-60, curwidth-120, 40);
    [promobutton setTitle:NSLocalizedString(@"View Promotions", nil) forState:UIControlStateNormal];
    [promobutton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
    [promobutton setBackgroundColor:[UIColor whiteColor]];
    promobutton.layer.borderWidth = 0.5f;
    promobutton.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    promobutton.layer.cornerRadius = 20.0f;
    [promobutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [promobutton addTarget:self action:@selector(selectpromo:) forControlEvents:UIControlEventTouchUpInside];
    
    [secpanel addSubview:queryqrcode];
    [secpanel addSubview:currencylabel];
    [secpanel addSubview:dollarsign];
    [secpanel addSubview:todaylabel];
    [secpanel addSubview:promobutton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    //[standardUser setObject:[NSString stringWithFormat:@"%f",[[UIScreen mainScreen] brightness]] forKey:@"currentbrightness"];
    //NSLog(@"current read %@", [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] brightness]]);
}

static writefiles *extracted(FirstViewController *object) {
    return object->writefileclass;
}

-(void)viewDidAppear:(BOOL)animated {
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
    [self checkinfo];
    writefileclass = [[writefiles alloc] init];
    [extracted(self) setpageview:@"front.view"];
    [self createtranscation];
    
}

-(IBAction)dismissscreen:(id)sender {
    NSLog(@"dismiss view");
}

-(void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view did disappear");
    //float brightnessvalue = [[standardUser objectForKey:@"currentbrightness"] floatValue];
    //[[UIScreen mainScreen] setBrightness:brightnessvalue];
    [locationManager stopUpdatingLocation];
    
}

-(void)showtheqr {
    showqrview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    showqrview.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    
    //swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeview)];
    //swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    //[showqrview addGestureRecognizer:swipeGesture];
    
    tangesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeview)];
    [showqrview addGestureRecognizer:tangesture];
    //pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveview)];
    //[showqrview addGestureRecognizer:pangesture];
    
    [self createQR];
    [self.view addSubview:showqrview];
}

-(void)closeview {
    NSLog(@"close view");
    [showqrview removeFromSuperview];
}

-(void)selectpromo:(id)sender {
    NSLog(@"open webview");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    promoview = [storyboard instantiateViewControllerWithIdentifier:@"adview"];
    
    [self presentViewController:promoview animated:YES completion:nil];
}
-(void)testbackground {
    NSLog(@"test backtorund thread");
}
-(void)cancelallsession:(id)sender {
    NSLog(@"logout");
    [standardUser removeObjectForKey:@"MerchID"];
    [standardUser removeObjectForKey:@"loginid"];
    [standardUser removeObjectForKey:@"requsttime"];
    [standardUser removeObjectForKey:@"responsetime"];
    [standardUser removeObjectForKey:@"signtoken"];
    [standardUser removeObjectForKey:@"signature_secret"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    loginview = [storyboard instantiateViewControllerWithIdentifier:@"loginview"];
    
    [self presentViewController:loginview animated:YES completion:nil];
    
}
-(void)imagetosave {
    NSString *urlstring = [standardUser objectForKey:@"qrcodestring"];
    NSData *stringData = [urlstring dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter *qrfilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrfilter setValue:stringData forKey:@"inputMessage"];
    [qrfilter setValue:@"L" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCodeImage = qrfilter.outputImage;
    CGRect imagesize = CGRectIntegral(qrCodeImage.extent);
    CGSize outputsize = CGSizeMake(400, 400);
    CIImage *imageResize = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputsize.width/CGRectGetWidth(imagesize), outputsize.height/CGRectGetHeight(imagesize))];
    UIImage *imageset = [[UIImage alloc] initWithCIImage:imageResize];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basepath = [paths objectAtIndex:0];
    NSString *filePath = [basepath stringByAppendingPathComponent:@"str_qrcode.png"];
    NSData *binaryImageData = UIImagePNGRepresentation(imageset);
    [binaryImageData writeToFile:filePath atomically:YES];
}
-(void)longpress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"longTouch UIGestureRecognizerStateBegan");
        NSString *urlstring = [standardUser objectForKey:@"qrcodestring"];
        NSData *stringData = [urlstring dataUsingEncoding: NSUTF8StringEncoding];
        CIFilter *qrfilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrfilter setValue:stringData forKey:@"inputMessage"];
        [qrfilter setValue:@"L" forKey:@"inputCorrectionLevel"];
        
        CIImage *qrCodeImage = qrfilter.outputImage;
        CGRect imagesize = CGRectIntegral(qrCodeImage.extent);
        CGSize outputsize = CGSizeMake(400, 400);
        CIImage *imageResize = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputsize.width/CGRectGetWidth(imagesize), outputsize.height/CGRectGetHeight(imagesize))];
        UIImage *imageset = [[UIImage alloc] initWithCIImage:imageResize];
        NSArray *items = @[imageset];
        
        UIActivityViewController *AV_controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        [self presentViewController:AV_controller animated:YES completion:^{}];
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)presentActivityController:(UIActivityViewController *)controller {
    
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

@end
