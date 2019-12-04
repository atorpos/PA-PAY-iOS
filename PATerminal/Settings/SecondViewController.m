//
//  SecondViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "SecondViewController.h"
#import "LoginViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import "AboutViewController.h"
#import "HelpViewController.h"
#import "faqViewController.h"
#import "announcementsViewController.h"
#import "legalViewController.h"
#import "EditAccountViewController.h"
#import "AllProductViewController.h"
#import "Communication.h"
#import "writefiles.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
@synthesize tableview, securityswitch, modeswitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    standardUser = [NSUserDefaults standardUserDefaults];
    context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"";
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        if (@available(iOS 11.0, *)) {
            if (context.biometryType == LABiometryTypeFaceID) {
                NSLog(@"face id");
                noofsection = 2;
                securtiytext = @"Face ID";
            } else if (context.biometryType == LABiometryTypeTouchID) {
                NSLog(@"touch id");
                noofsection = 2;
                securtiytext = @"Touch ID";
            }
        } else {
            NSLog(@"not ios 11");
            noofsection = 2;
            // Fallback on earlier versions
        }
    } else {
        NSLog(@"no bio");
        noofsection = 2;
    }
    
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    tableview.delegate = self;
    tableview.dataSource = self;
    
    [self.view addSubview:tableview];
    NSLog(@"%@",[standardUser objectForKey:@"launchlocation"] );
}
-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"second view %@", [standardUser objectForKey:@"lastlocation"]);
    NSArray *curlocation = [[standardUser objectForKey:@"lastlocation"] componentsSeparatedByString:@"+"];
    CLLocation *locationActual = [[CLLocation alloc] initWithLatitude:[curlocation[0] floatValue] longitude:[curlocation[1] floatValue]];
    [self reverseGeocode:locationActual];
    writefileclass = [[writefiles alloc] init];
    writefileclass.updatelocation = [standardUser objectForKey:@"lastlocation"];
    [writefileclass setpageview:@"settings.view"];
    
}
-(void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
            self->addressString = [lines componentsJoinedByString:@"\n"];
            NSLog(@"Address %@", self->addressString);
            [self->textaddress setText:self->addressString];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table view methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return noofsection;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int noofrowsection;
    switch (section) {
        case 0:
            noofrowsection = 2;
            break;
        case 1:
            noofrowsection = 4;
            break;
        case 2:
            noofrowsection = 1;
            break;
        case 3:
            noofrowsection = 1;
            break;
        case 4:
            noofrowsection = 1;
            break;
        default:
            noofrowsection = 1;
            break;
    }
    return noofrowsection;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [tableview dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    switch (indexPath.section) {
        case 0:
        {
            if ([standardUser objectForKey:@"MerchID"] != nil) {
                switch (indexPath.row) {
                    case 1:
                    {
                        UIButton *editbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        editbutton.frame = CGRectMake(8, 2, curwidth-16, 36);
                        editbutton.titleLabel.font = [UIFont systemFontOfSize:17];
                        [editbutton setTitle:NSLocalizedString(@"Edit Account", nil) forState:UIControlStateNormal];
                        [editbutton addTarget:self action:@selector(editviewopen:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:editbutton];
                        
                    }
                        break;
                    case 0:
                    {
                        logoutbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        logoutbutton.frame = CGRectMake(8,2, curwidth-16, 36);
                        logoutbutton.titleLabel.font = [UIFont systemFontOfSize:17];
                        [logoutbutton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
                        [logoutbutton addTarget:self action:@selector(cancelallsession:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:logoutbutton];
                    }
                        break;
                    default:
                        break;
                }
            } else {
                switch (indexPath.row) {
                    case 0:
                    {
                        UIButton *signinbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        signinbutton.frame = CGRectMake(8, 5, curwidth-16, 30);
                        signinbutton.titleLabel.font = [UIFont systemFontOfSize:17];
                        [signinbutton setTitle:@"Sign in" forState:UIControlStateNormal];
                        [signinbutton addTarget:self action:@selector(loginview:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:signinbutton];
                        break;
                    }
                        
                    case 1:
                    {
                        registbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        registbutton.frame = CGRectMake(8, 5, curwidth-16, 30);
                        registbutton.titleLabel.font = [UIFont systemFontOfSize:17];
                        [registbutton setTitle:@"Sign up of Account" forState:UIControlStateNormal];
                        [registbutton addTarget:self action:@selector(webview:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:registbutton];
                        break;
                    }
                    default:
                        break;
                }
                
            }
        }
            break;
        case 4:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"All Items", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 5:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"Printers", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UILabel *usingbio = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, curwidth/2, 30)];
                    usingbio.text = [NSString stringWithFormat:NSLocalizedString(securtiytext, nil)];
                    [cell.contentView addSubview:usingbio];
                    securityswitch = [[UISwitch alloc] initWithFrame:CGRectMake(curwidth-60, 5, 50, 30)];
                    securityswitch.transform = CGAffineTransformMakeScale(0.80, 0.80);
                    //[self->standardUser setObject:@"1" forKey:@"bioauth"];
                    if ([self->standardUser objectForKey:@"bioauth"]) {
                        NSLog(@"the bio auth %@", [self->standardUser objectForKey:@"bioauth"]);
                        switch ([[self->standardUser objectForKey:@"bioauth"] integerValue]) {
                            case 0:
                            {
                                [securityswitch setOn:NO];
                            }
                                break;
                            case 1:
                            {
                                [securityswitch setOn:YES];
                            }
                                break;
                            default:
                                break;
                        }
                    }
                    [securityswitch addTarget:self action:@selector(switchon:) forControlEvents:UIControlEventValueChanged];
                    [cell.contentView addSubview:securityswitch];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 6:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIButton *gotoaddress = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    gotoaddress.frame = CGRectMake(8, 5, curwidth-16, 30);
                    [gotoaddress addTarget:self action:@selector(gotomap:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.contentView addSubview:gotoaddress];
                    textaddress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, curwidth-16, 30)];
                    textaddress.text = addressString;
                    textaddress.font = [UIFont systemFontOfSize:17];
                    [gotoaddress addSubview:textaddress];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Help", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"FAQ", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                //case 2:
                //    cell.textLabel.text = NSLocalizedString(@"Announcements", nil);
                //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                //    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"About", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"Terms of Services", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"QRCode Mode", nil);
                    modeswitch = [[UISwitch alloc] initWithFrame:CGRectMake(curwidth-60, 5, 50, 30)];
                    modeswitch.transform = CGAffineTransformMakeScale(0.80, 0.80);
                    if([self->standardUser objectForKey:@"qrcodemode"]) {
                        switch ([[self->standardUser objectForKey:@"qrcodemode"] integerValue]) {
                            case 0:
                            {
                                [modeswitch setOn:NO];
                            }
                                break;
                            case 1:
                            {
                                [modeswitch setOn:YES];
                            }
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    [modeswitch addTarget:self action:@selector(qrcodemode:) forControlEvents:UIControlEventValueChanged];
                    [cell.contentView addSubview:modeswitch];
                }
                    
                    break;
                    
                default:
                    break;
            }
        }
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"Account", nil);
            break;
        case 2:
            sectionName = NSLocalizedString(@"POS Mode", nil);
            break;
        case 5:
            sectionName = NSLocalizedString(@"Your pervious use location", nil);
            break;
        case 3:
            sectionName = NSLocalizedString(@"Hardware", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"Support", nil);
            break;
        case 4:
            sectionName = NSLocalizedString(@"Items", nil);
            break;
        default:
            break;
    }
    return sectionName;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (indexPath.section) {
        case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        helpview = [storyboard instantiateViewControllerWithIdentifier:@"helpview"];
                        [self.navigationController pushViewController:helpview animated:YES];
                    }
                        break;
                    case 1:
                    {
                        faqview = [storyboard instantiateViewControllerWithIdentifier:@"faqview"];
                        [self.navigationController pushViewController:faqview animated:YES];
                    }
                        break;
                    //case 2:
                    //{
                    //    annocview = [storyboard instantiateViewControllerWithIdentifier:@"announcementview"];
                    //    [self.navigationController pushViewController:annocview animated:YES];
                    //}
                    //    break;
                    case 2:
                    {
                        //aboutview = [storyboard instantiateViewControllerWithIdentifier:@"aboutivew"];
                        //[self.navigationController pushViewController:aboutview animated:YES];
                        NSURL *aboutURL = [NSURL URLWithString:@"https://www.paymentasia.com"];
                        [[UIApplication sharedApplication] openURL:aboutURL];
                    }
                        break;
                    case 3:
                    {
                        legalview = [storyboard instantiateViewControllerWithIdentifier:@"legalview"];
                        [self.navigationController pushViewController:legalview animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }
            break;
        case 4:
        {
            switch (indexPath.row) {
                case 0:
                    {
                        allview = [storyboard instantiateViewControllerWithIdentifier:@"allproductview"];
                        
                        [self.navigationController pushViewController:allview animated:YES];
                    }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 5:
        {
            switch (indexPath.row) {
                case 0:
                    {
                        NSLog(@"select printers");
                        [Communication connectBluetooth:^(BOOL result, NSString *title, NSString *message) {
                            if(title !=nil || message != nil) {
                                UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                                               message:message
                                                                                        preferredStyle:UIAlertControllerStyleAlert];

                                
                                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                                [alert addAction:defaultAction];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                        }];
                    }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    
}
-(IBAction)switchon:(id)sender {
    UISwitch *switchObj = (UISwitch *)sender;
    if(switchObj.isOn) {
        NSLog(@"value is on");
        NSError *authError = nil;
        NSString *Localreasonstring = @"Bio ID test is on";
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:Localreasonstring reply:^(BOOL success, NSError *error) {
                if(success) {
                    NSLog(@"success");
                    [self->standardUser setObject:@"1" forKey:@"bioauth"];
                } else {
                    NSLog(@"fail");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->securityswitch setOn:NO animated:YES];
                    });
                    [self->standardUser setObject:@"0" forKey:@"bioauth"];
                }
            }];
        } else {
            NSLog(@"no thing");
        }
    } else {
        NSLog(@"the value is off");
        [self->standardUser setObject:@"0" forKey:@"bioauth"];
    }
}

-(IBAction)qrcodemode:(id)sender {
    UISwitch *switchObj = (UISwitch *)sender;
    if(switchObj.isOn) {
        NSLog(@"it is on");
        [self->standardUser setObject:@"1" forKey:@"qrcodemode"];
    } else {
        NSLog(@"it is off");
        [self->standardUser setObject:@"0" forKey:@"qrcodemode"];
    }
}
-(void)cancelallsession:(id)sender {
    NSLog(@"logout");
    NSUserDefaults *standarduser = [NSUserDefaults standardUserDefaults];
    [standarduser removeObjectForKey:@"MerchID"];
    [standarduser removeObjectForKey:@"loginid"];
    [standarduser removeObjectForKey:@"requsttime"];
    [standarduser removeObjectForKey:@"responsetime"];
    [standarduser removeObjectForKey:@"signtoken"];
    [standarduser removeObjectForKey:@"signature_secret"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    loginview = [storyboard instantiateViewControllerWithIdentifier:@"loginview"];
    
    [self presentViewController:loginview animated:YES completion:nil];
    
}
-(void)gotomap:(id)sender {
    NSString *refineadd = [addressString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *appleURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@",refineadd]];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:appleURL options:@{} completionHandler:^(BOOL success){}];
    } else {
        [[UIApplication sharedApplication] openURL:appleURL];
    }
    
}
-(void)webview:(id)sender {
    NSLog(@"open webview");
    
}
-(void)editviewopen:(id)sender {
    NSLog(@"open edit view");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    editview = [storyboard instantiateViewControllerWithIdentifier:@"editview"];
    [self.navigationController pushViewController:editview animated:YES];
}
-(void)loginview:(id)sender {
    NSLog(@"open login view");
}

@end
