//
//  LoginViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "LoginViewController.h"
#import "FirstViewController.h"
#import "tandcViewController.h"
#import "SBJson5.h"
#import "services.pch"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize merchantid, terminalid, passwdfld, loginbutton, regisbutton, forgetpasswd, taprecognizer, qrloginbutton;

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    
    NSLog(@"it is the first view");
    standardef = [NSUserDefaults standardUserDefaults];
    if ([standardef objectForKey:@"ischecked"]) {
        ischeck = @"ischecked";
    }
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundclick:)];
    taprecognizer.cancelsTouchesInView = NO;
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
    UIImageView *backgroundview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    backgroundview.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *backgroundimage = [UIImage imageNamed:@"login_1.png"];
    
    [backgroundview setImage:backgroundimage];
    [self.view addSubview:backgroundview];
    //[self.view addSubview:backgroundview];
    [self.view addGestureRecognizer:taprecognizer];
    [self createui];

}
-(void)createui {
    //UIImage *bgimg = [UIImage imageNamed:@"app_background.png"];
    //UIImageView *mainview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    //[mainview setImage:bgimg];
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            loginbgview = [[UIView alloc] initWithFrame:CGRectMake(10, 60, curwidth-20, 430)];
            loginbgview.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
            loginbgview.layer.cornerRadius = 10.0;
        } else {
            loginbgview = [[UIView alloc] initWithFrame:CGRectMake(10, 60, curwidth-20, 430)];
            loginbgview.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
            loginbgview.layer.cornerRadius = 10.0;
        }
    } else {
        // Fallback on earlier versions
    }
    
    
    
    UIImageView *logoview = [[UIImageView alloc] initWithFrame:CGRectMake(loginbgview.frame.size.width/2-122, 30, 244, 59)];
    UIImage *applogo = [UIImage imageNamed:@"OpeningPG_logo.png"];
    logoview.contentMode = UIViewContentModeScaleAspectFit;
    [logoview setImage:applogo];
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    
    
    merchantid = [[UITextField alloc] initWithFrame:CGRectMake(30, 110, loginbgview.frame.size.width-60, 40)];
    border.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor;
    border.frame = CGRectMake(0, merchantid.frame.size.height - borderWidth, merchantid.frame.size.width, merchantid.frame.size.height);
    border.borderWidth = borderWidth;
    [merchantid.layer addSublayer:border];
    [merchantid setKeyboardType:UIKeyboardTypeASCIICapable];
    merchantid.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Merchant ID", nil)];
    if([standardef objectForKey:@"merchantidinput"]) {
        merchantid.text = [standardef objectForKey:@"merchantidinput"];
    }
    merchantid.userInteractionEnabled = YES;
    merchantid.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; //make cap letter
    merchantid.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
    merchantid.textAlignment = NSTextAlignmentCenter;
    merchantid.layer.masksToBounds = true;
    merchantid.delegate = self;
    [merchantid isEditing];
    
    CALayer *border1 = [CALayer layer];
    
    terminalid = [[UITextField alloc] initWithFrame:CGRectMake(30, 170, loginbgview.frame.size.width-60, 40)];
    border1.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor;
    border1.frame = CGRectMake(0, terminalid.frame.size.height - borderWidth, terminalid.frame.size.width, terminalid.frame.size.height);
    border1.borderWidth = borderWidth;
    [terminalid.layer addSublayer:border1];
    [terminalid setKeyboardType:UIKeyboardTypeNumberPad];
    terminalid.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Terminal ID", nil)];
    if([standardef objectForKey:@"terminalidinput"]) {
        terminalid.text = [standardef objectForKey:@"terminalidinput"];
    }
    terminalid.userInteractionEnabled = YES;
    terminalid.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];\
    terminalid.textAlignment = NSTextAlignmentCenter;
    terminalid.layer.masksToBounds = true;
    terminalid.delegate = self;
    [terminalid isEditing];
    
    CALayer *border2 = [CALayer layer];
    
    passwdfld = [[UITextField alloc] initWithFrame:CGRectMake(30, 230, loginbgview.frame.size.width-60, 40)];
    border2.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1].CGColor;
    border2.frame = CGRectMake(0, passwdfld.frame.size.height - borderWidth, passwdfld.frame.size.width, passwdfld.frame.size.height);
    border2.borderWidth = borderWidth;
    [passwdfld.layer addSublayer:border2];
    passwdfld.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Password", nil)];
    passwdfld.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
    passwdfld.textAlignment = NSTextAlignmentCenter;
    passwdfld.userInteractionEnabled = YES;
    passwdfld.secureTextEntry = YES;
    passwdfld.layer.masksToBounds = true;
    passwdfld.delegate = self;
    [passwdfld isEditing];
    
//    regisbutton = [UIButton buttonWithType:UIButtonTypeCustom];
//    regisbutton.frame = CGRectMake(loginbgview.frame.size.width/4, 360, loginbgview.frame.size.width/2, 40);
//    [regisbutton setTitle:@"Sign up" forState:UIControlStateNormal];
//    [regisbutton setTitleColor:[UIColor colorWithRed:0.35 green:0.42 blue:0.85 alpha:1] forState:UIControlStateNormal];
//    [regisbutton addTarget:self action:@selector(regist:) forControlEvents:UIControlEventTouchUpInside];
    //[regisbutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    loginbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginbutton.frame = CGRectMake(30, 300, loginbgview.frame.size.width-60, 40);
    [loginbutton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [loginbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginbutton setBackgroundColor:[UIColor colorWithRed:0.13 green:0.40 blue:1.0 alpha:1]];
    loginbutton.layer.borderWidth = 0.5f;
    loginbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    loginbutton.layer.cornerRadius = 20.0f;
    [loginbutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [loginbutton addTarget:self action:@selector(sendlogin:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:mainview];
    
    [loginbgview addSubview:logoview];
    [loginbgview addSubview:merchantid];
    [loginbgview addSubview:terminalid];
    [loginbgview addSubview:passwdfld];
    [loginbgview addSubview:loginbutton];
//    [loginbgview addSubview:regisbutton];
    
    qrloginbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    qrloginbutton.frame = CGRectMake(30, 360, loginbgview.frame.size.width-60, 24);
    [qrloginbutton setTitle:NSLocalizedString(@"QRCode Login", nil) forState:UIControlStateNormal];
    [qrloginbutton setTitleColor:[UIColor colorWithRed:0.13 green:0.4 blue:1.0 alpha:1] forState:UIControlStateNormal];
    
//    [loginbgview addSubview:qrloginbutton];

    [self.view addSubview:loginbgview];
    UILabel *viewtnc = [[UILabel alloc] initWithFrame:CGRectMake(10, curheigh-35, curwidth-20, 15)];
    viewtnc.text = NSLocalizedString(@"View Payment Asia's Terms, Privacy Policy, and E-Sign Consent", nil);
    viewtnc.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
    viewtnc.adjustsFontSizeToFitWidth = YES;
    
    //[self.view addSubview:viewtnc];
}
-(void)creatandaccept {
    UILabel *clickandaccept  = [[UILabel alloc] init];
    clickandaccept.frame = CGRectMake(30, 290, loginbgview.frame.size.width-120, 40);
    clickandaccept.text = NSLocalizedString(@"Accept Payment Asia's Terms, Privacy Policy, and E-Sign Consent", nil);
    clickandaccept.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    clickandaccept.lineBreakMode = NSLineBreakByWordWrapping;
    clickandaccept.numberOfLines = 0;
    [loginbgview addSubview:clickandaccept];
    UIButton *clickbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    clickbutton.frame = CGRectMake(loginbgview.frame.size.width-50, 300, 20, 20);
    [clickbutton addTarget:self action:@selector(checkcheck:) forControlEvents:UIControlEventTouchUpInside];
    clickedimgview = [[UIImageView alloc] init];
    clickedimgview.frame = CGRectMake(0, 0, clickbutton.frame.size.width, clickbutton.frame.size.height);
    [clickedimgview setImage:[UIImage imageNamed:@"uncheck.png"]];
    [clickbutton addSubview:clickedimgview];
    [loginbgview addSubview:clickbutton];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *c = [locations objectAtIndex:0];
    MKCoordinateRegion region;
    CLLocationCoordinate2D setCoord;
    setCoord.latitude = c.coordinate.latitude;
    setCoord.longitude = c.coordinate.longitude;
    region.center = setCoord;
    //NSLog(@"here is the location %f, %f", region.center.latitude, region.center.longitude);
    
    [standardef setObject:[NSString stringWithFormat:@"%f+%f", region.center.latitude, region.center.longitude] forKey:@"updatelocation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)checkcheck:(id)sender {
    NSLog(@"touch up inside");
    if(![standardef objectForKey:@"ischecked"]) {
        [clickedimgview setImage:[UIImage imageNamed:@"check.png"]];
        [standardef setObject:@"ischeck" forKey:@"ischecked"];
        loginbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginbutton.frame = CGRectMake(30, 350, loginbgview.frame.size.width-60, 40);
        [loginbutton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
        [loginbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginbutton setBackgroundColor:[UIColor colorWithRed:0.27 green:0.46 blue:0.66 alpha:1]];
        loginbutton.layer.borderWidth = 0.5f;
        loginbutton.layer.borderColor = [UIColor whiteColor].CGColor;
        loginbutton.layer.cornerRadius = 20.0f;
        [loginbutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [loginbutton addTarget:self action:@selector(sendlogin:) forControlEvents:UIControlEventTouchUpInside];
        [loginbgview addSubview:loginbutton];
        
        forgetpasswordbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        forgetpasswordbutton.frame = CGRectMake(30, 410, loginbgview.frame.size.width-60, 30);
        [forgetpasswordbutton setTitle:NSLocalizedString(@"Forget Pasword", nil) forState:UIControlStateNormal];
        forgetpasswordbutton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
        
    } else {
        [loginbutton removeFromSuperview];
        [standardef removeObjectForKey:@"ischecked"];
        [clickedimgview setImage:[UIImage imageNamed:@"uncheck.png"]];
        
    }
    
}

-(IBAction)sendlogin:(id)sender {
    [self loadingview];
    if (![merchantid.text  isEqual: @""] && ![terminalid.text  isEqual: @""] && ![passwdfld.text  isEqual: @""]) {
        NSLog(@"send login %@, %@, %@, %@", merchantid.text, terminalid.text, passwdfld.text, [standardef objectForKey:@"fcmtoken"]);
        NSString *sentlogin = [NSString stringWithFormat:@"merchant_id=%@&terminal_id=%@&password=%@&fcm_device_token=%@",merchantid.text,terminalid.text, passwdfld.text,[standardef objectForKey:@"fcmtoken"]];
        NSString *loginuid= [NSString stringWithFormat:@"%@%@", PRODUCTIONURL, LOGIN_ENDPOINT];
        NSLog(@"login url %@", loginuid);
        
        NSData *postdata = [sentlogin dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[sentlogin length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:loginuid]];
        [request setHTTPMethod:@"POST"];
        [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postdata];
        [request setTimeoutInterval:10.0];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (response &&! error) {
                self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [self performSelectorOnMainThread:@selector(fetchresponse:) withObject:data waitUntilDone:YES];
            }
        }];
        [task resume];
    } else {
        NSString *errormsg = @"nil info";
        [self stoploadingview];
        [self performSelectorOnMainThread:@selector(errormsg:) withObject:errormsg waitUntilDone:YES];
    }
}

-(IBAction)regist:(id)sender {
    NSURL *aboutURL = [NSURL URLWithString:EXTERNAL_URL];
    [[UIApplication sharedApplication] openURL:aboutURL options:@{} completionHandler:^(BOOL success){
        if(success) {
            
        }
    }];
    
}
-(void)loadingview {
    loadingbgview = [[UIView alloc] init];
    loadingbgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    loadingbgview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:loadingbgview];
    loadingviewsp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [loadingviewsp setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingviewsp];
    [loadingviewsp startAnimating];
    
}
-(void)stoploadingview {
    [loadingviewsp stopAnimating];
    [loadingviewsp removeFromSuperview];
    [loadingbgview removeFromSuperview];
}
-(void)fetchresponse:(NSData *)responseData {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    signid = [[json valueForKey:@"request"] valueForKey:@"id"];
    
    
    //[standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"transactions"] forKey:@"transactions"];
    if([[[json valueForKey:@"response"] valueForKey:@"code"] intValue]== 200) {
        NSLog(@"get take %@ and %@", json, [[[json valueForKey:@"payload"] valueForKey:@"provider"] objectAtIndex:0]);
        [standardef setObject:merchantid.text forKey:@"merchantidinput"];
        [standardef setObject:terminalid.text forKey:@"terminalidinput"];
        [standardef setObject:merchantid.text forKey:@"MerchID"];
        [standardef setObject:terminalid.text forKey:@"terminalid"];
        [standardef setObject:passwdfld.text forKey:@"userpassword"];
        [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"provider"] forKey:@"channels"];
        transcationurl = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL, TRANSACTION_ENDPOINT];
        [standardef setObject:@"0" forKey:@"bioauth"];
        if([[[json valueForKey:@"payload"] valueForKey:@"tnc"] integerValue] == 0) {
            tncview = [self.storyboard instantiateViewControllerWithIdentifier:@"tndcview"];
            tncview.jsondm = json;
            [self stoploadingview];
            [self presentViewController:tncview animated:YES completion:nil];
        } else {
            firstview = [self.storyboard instantiateViewControllerWithIdentifier:@"MainView"];
            //[self checktranscation];
            [standardef setObject:[[json valueForKey:@"request"] valueForKey:@"id"] forKey:@"loginid"];
            [standardef setObject:[[json valueForKey:@"request"] valueForKey:@"time"] forKey:@"requsttime"];
            [standardef setObject:[[json valueForKey:@"response"] valueForKey:@"time"] forKey:@"responsetime"];
            [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"token"] forKey:@"signtoken"];
            [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"signature_secret"] forKey:@"signature_secret"];
            [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"screen_saver"] forKey:@"ad_screensaver"];
            [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"qrcode"] forKey:@"qrcodestring"];
            [standardef setObject:[[json valueForKey:@"payload"] valueForKey:@"merchant_name"] forKey:@"merchant_name"];
            [self stoploadingview];
            [self presentViewController:firstview animated:YES completion:nil];
        }
        
    } else {
        NSLog(@"%@", json);
        [self stoploadingview];
        [self performSelectorOnMainThread:@selector(errormsg:) withObject:[[json valueForKey:@"response"] valueForKey:@"message"] waitUntilDone:YES];
    }
    NSLog(@"login id %@", signid);
}
-(IBAction)backgroundclick:(id)sender {
    
    [[self view] endEditing:YES];
}
-(void)checktranscation{
    NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standardef objectForKey:@"signtoken"]];
    NSLog(@"submit log %@", posttoken);
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:transcationurl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            NSString *newstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"back requeste %@", newstr);
            [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
        } else {
        }
    }];
    
    [task resume];
}
-(void)fetchdata:(NSData *)requestdata {
    NSError *error;
    NSDictionary *trajson = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    NSLog(@"data %@", trajson);
    noofrow = (int)[[[trajson valueForKey:@"payload"] valueForKey:@"transactions"] count];
    if (noofrow != 0) {
        [standardef setObject:[[[trajson valueForKey:@"payload"] valueForKey:@"transactions"] valueForKey:@"status"] forKey:@"transcation"];
    } else {
        
    }
}
-(void)errormsg :(NSString *)response{
    if([response isEqualToString:@"Invalid Credential"]) {
        errorstr = [NSString stringWithFormat:NSLocalizedString(@"Invalid Login information", nil)];
    } else {
        errorstr = [NSString stringWithFormat:NSLocalizedString(@"Enter all login informations", nil)];
    }
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:errorstr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:ok];
    [self presentViewController:alertcontroller animated:YES completion:nil];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
