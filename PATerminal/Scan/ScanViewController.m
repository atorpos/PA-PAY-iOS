//
//  ScanViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/13.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import "ScanViewController.h"
#import "FinishedViewController.h"
#import <CoreImage/CoreImage.h>
#import "SBJson5Parser.h"
#import <QuartzCore/QuartzCore.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import "writefiles.h"
#import "services.pch"

@interface ScanViewController () 

@end

@implementation ScanViewController
@synthesize chargingvalue, qrcodedeco, imageview, capturesession, videoPreviewLayer, centralManager, data, discoveredPeripheral, transferCharacteristic, audioPlayer;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadingBeep];
    [[self navigationController] setNavigationBarHidden:YES];
    defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"the channel %@", [defaults objectForKey:@"channels"]);
    
    requesturl = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL, REQUEST_ENDPOINT];
    querystring = [NSString stringWithFormat:@"%@%@",PRODUCTIONURL,QUERY_ENDPOINT];
    acquireqrcodeurl = [NSString stringWithFormat:@"%@%@", PRODUCTIONURL, ONETIME_ENDPOINT];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    data = [[NSMutableData alloc] init];
    
    [self createview];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBManagerStatePoweredOn) {
        [centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if(discoveredPeripheral != peripheral) {
        discoveredPeripheral = peripheral;
    }
    NSLog(@"Connecting to peripheral %@", peripheral);
    [centralManager connectPeripheral:peripheral options:nil];
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}
-(void)cleanup {
    // See if we are subscribed to a characteristic on the peripheral
    if (discoveredPeripheral.services != nil) {
        for (CBService *service in discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [centralManager cancelPeripheralConnection:discoveredPeripheral];
    
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connect");
    
    [centralManager stopScan];
    NSLog(@"stop scan");
    [data setLength:0];
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    NSString *senddata = @"0x0C";
    NSData *tansferdata = [[NSData alloc] init];
    tansferdata = [senddata dataUsingEncoding:NSUTF8StringEncoding];
    CBMutableCharacteristic *mutab_char = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWrite value:tansferdata permissions:CBAttributePermissionsWriteable];
    
    
    NSLog(@"%@", tansferdata);
    [peripheral writeValue:tansferdata forCharacteristic:mutab_char type:CBCharacteristicWriteWithResponse];
    //[peripheral writeValue:tansferdata forCharacteristic:CBCharacteristicWriteWithoutResponse type:CBCharacteristicPropertyWrite];
}

-(void)createview {
    [doneview removeFromSuperview];
    [bottomview removeFromSuperview];
    [rescanbutton removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    bgimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    [bgimage setImage:[UIImage imageNamed:@"app_background.png"]];
    [self.view addSubview:bgimage];
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    CGFloat topPadding = window.safeAreaInsets.top;
    
    NSLog(@"show safe are insit %f", topPadding);
    upperbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 44+topPadding)];
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            upperbar.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
        } else {
            upperbar.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
        }
    } else {
        upperbar.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
    }
    
    
    cancelbutton = [[UIButton alloc] initWithFrame:CGRectMake(5, topPadding+44/2-10, 80, 20)];
    cancelbutton.backgroundColor = [UIColor clearColor];
    [cancelbutton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [cancelbutton setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [cancelbutton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [cancelbutton addTarget:self action:@selector(cancelpage:) forControlEvents:UIControlEventTouchUpInside];
    
    qrcodedeco = [[UILabel alloc]init];
    qrcodedeco.frame = CGRectMake(0, topPadding+44/2-10, curwidth, 20);
    qrcodedeco.text = NSLocalizedString(@"Scan QRcode", nil);
    qrcodedeco.textAlignment = NSTextAlignmentCenter;
    qrcodedeco.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    qrcodedeco.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    
    thecamview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    thecamview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelpage:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [thecamview addGestureRecognizer:swipeGesture];
    
    
    
    [upperbar addSubview:cancelbutton];
    [upperbar addSubview:qrcodedeco];
    
    [self.view addSubview:thecamview];
    
    
    //[info_view addSubview:info_label];
    [self.view setNeedsDisplay];
    bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, curwidth/2+curheigh/2, curwidth, curheigh-curwidth/2-curheigh/2)];
    bottomview.backgroundColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:0.6];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualeffectview;
    visualeffectview.alpha = 0.3;
    visualeffectview = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualeffectview.frame = bottomview.bounds;
    [bottomview addSubview:visualeffectview];
    
    topview = [[UIView alloc] initWithFrame:CGRectMake(0, 70, curwidth, curheigh/5)];
    topview.backgroundColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1.0];
    [self.view addSubview:topview];
   
    substitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, bottomview.frame.size.width, 17)];
    substitle.backgroundColor = [UIColor clearColor];
    substitle.text = NSLocalizedString(@"Align QR code within the image to scan", nil);
    substitle.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    substitle.textAlignment = NSTextAlignmentCenter;
    substitle.textColor = [UIColor whiteColor];
    
    [self creatonetimebutton];
    
    //[bottomview addSubview:info_view];
    [bottomview addSubview:substitle];
    [self.view addSubview:bottomview];
    [self.view addSubview:upperbar];
}
-(void)creatonetimebutton {
    NSLog(@"show channel %lu", (unsigned long)[[defaults objectForKey:@"channels"] count]);
    if ([[defaults objectForKey:@"channels"] containsObject:@"WECHATOFFLINE"]) {
        UIButton *showechatcode = [UIButton buttonWithType:UIButtonTypeCustom];
        showechatcode.frame = CGRectMake(curwidth-84*2, 37, 64, 64);
        [showechatcode setTitle:@"" forState:UIControlStateNormal];
        [showechatcode setBackgroundColor:[UIColor whiteColor]];
        [showechatcode setTitleColor:[UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1] forState:UIControlStateNormal];
        showechatcode.layer.borderColor = [UIColor whiteColor].CGColor;
        showechatcode.layer.borderWidth = 0.5f;
        showechatcode.layer.cornerRadius = 32;
        [showechatcode addTarget:self action:@selector(getonetimeqrcode:) forControlEvents:UIControlEventTouchUpInside];
        showechatcode.tag = 1;
        UIImageView *apicnview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wechat_c.png"]];
        apicnview.frame = CGRectMake(10, 10, showechatcode.frame.size.width-20, showechatcode.frame.size.height-20);
        [showechatcode addSubview:apicnview];
        
        
        [bottomview addSubview:showechatcode];
    }
    if ([[defaults objectForKey:@"channels"] containsObject:@"CUPOFFLINE"]) {
        UIButton *showunioncode = [UIButton buttonWithType:UIButtonTypeCustom];
        showunioncode.frame = CGRectMake(curwidth-84*3, 37, 64, 64);
        [showunioncode setTitle:@"" forState:UIControlStateNormal];
        [showunioncode setBackgroundColor:[UIColor whiteColor]];
        [showunioncode setTitleColor:[UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1] forState:UIControlStateNormal];
        showunioncode.layer.borderColor = [UIColor whiteColor].CGColor;
        showunioncode.layer.borderWidth = 0.5f;
        showunioncode.layer.cornerRadius = 32;
        [showunioncode addTarget:self action:@selector(getonetimeqrcode:) forControlEvents:UIControlEventTouchUpInside];
        showunioncode.tag = 2;
        UIImageView *apicnview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unionpay_c.png"]];
        apicnview.frame = CGRectMake(10, 10, showunioncode.frame.size.width-20, showunioncode.frame.size.height-20);
        [showunioncode addSubview:apicnview];
        
        
        [bottomview addSubview:showunioncode];
    }
    if ([[defaults objectForKey:@"channels"] containsObject:@"ALIPAYOFFLINE"]) {
        UIButton *showqrcode = [UIButton buttonWithType:UIButtonTypeCustom];
        showqrcode.frame = CGRectMake(curwidth-84, 37, 64, 64);
        [showqrcode setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
        [showqrcode setBackgroundColor:[UIColor whiteColor]];
        [showqrcode setTitleColor:[UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1] forState:UIControlStateNormal];
        showqrcode.layer.borderColor = [UIColor whiteColor].CGColor;
        showqrcode.layer.borderWidth = 0.5f;
        showqrcode.layer.cornerRadius = 32;
        [showqrcode addTarget:self action:@selector(getonetimeqrcode:) forControlEvents:UIControlEventTouchUpInside];
        showqrcode.tag = 0;
        UIImageView *apicnview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alipay_icon.png"]];
        apicnview.frame = CGRectMake(10, 10, showqrcode.frame.size.width-20, showqrcode.frame.size.height-20);
        [showqrcode addSubview:apicnview];
        
        
        [bottomview addSubview:showqrcode];
    }
}

-(void)qrcamfnt {
    NSLog(@"run qr");
    //turn on the qr camera
    _isReading = NO;
    capturesession = nil;
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    scanlayoutview = [[UIImageView alloc] initWithFrame:CGRectMake(25, curheigh/2-(curwidth/2-50), curwidth-50, curwidth-50)];
    scanlayoutimg = [UIImage imageNamed:@"scan_layout.png"];
    [scanlayoutview setImage:scanlayoutimg];
    scanlayoutview.contentMode = UIViewContentModeScaleAspectFit;
    
    
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
                [catureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeEAN13Code, nil]];
                videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:capturesession];
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                videoPreviewLayer.frame = imageview.bounds;
                [imageview.layer addSublayer:videoPreviewLayer];
                [capturesession startRunning];
            }
        }
    }
    
    [thecamview addSubview:imageview];
    [thecamview addSubview:scanlayoutview];
    //end of QR cam
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] || [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode128Code]) {
            [capturesession stopRunning];
            [self performSelectorOnMainThread:@selector(loadingview) withObject:nil waitUntilDone:NO];
            NSLog(@"%@", [metadataObj stringValue]);
            scanqrcode = [metadataObj stringValue];
            //[qrcodedeco performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            //[self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(searchqr:) withObject:scanqrcode waitUntilDone:NO];
            _isReading = NO;
            if(audioPlayer) {
                [audioPlayer play];
            }
        }
    }
}

-(void)loadingview {
    loadingbgview = [[UIView alloc] init];
    loadingbgview.frame = CGRectMake(0, 0, curwidth, curheigh);
    loadingbgview.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:loadingbgview];
    loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    [loadingview setCenter:CGPointMake(curwidth/2, curheigh/2)];
    [loadingbgview addSubview:loadingview];
    [loadingview startAnimating];
    
}
-(void)notificview_fun {
    notificview = [[UIView alloc] initWithFrame:CGRectMake(10, 2*curwidth/3-5, curwidth-20, curwidth/2)];
    notificview.backgroundColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1];
    notificview.layer.masksToBounds = YES;
    //notificview.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    //notificview.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //notificview.layer.shadowOpacity = 0.5f;
    //notificview.layer.shadowPath = [UIBezierPath bezierPathWithRect:notificview.bounds].CGPath;
    CALayer* layer = [notificview layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1,layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor whiteColor].CGColor];
    [layer addSublayer:bottomBorder];
    
    UILabel *requestlable = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, notificview.frame.size.width-10, 17)];
    requestlable.textAlignment = NSTextAlignmentLeft;
    requestlable.text = [NSString stringWithFormat:@"ID: %@", request_reference];
    requestlable.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    requestlable.adjustsFontSizeToFitWidth = YES;
    
    UILabel *amountlabel = [[UILabel alloc] initWithFrame:CGRectMake(5, notificview.frame.size.height-22, (notificview.frame.size.width-10)/2, 17)];
    amountlabel.textAlignment = NSTextAlignmentLeft;
    amountlabel.text = @"HKD";
    amountlabel.textColor = [UIColor whiteColor];
    amountlabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    
    UILabel *amountvalue = [[UILabel alloc] initWithFrame:CGRectMake((notificview.frame.size.width)/2, notificview.frame.size.height-32, (notificview.frame.size.width-10)/2, 17)];
    amountvalue.textAlignment = NSTextAlignmentRight;
    amountvalue.text = chargingvalue;
    amountvalue.textColor = [UIColor whiteColor];
    amountvalue.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:15];
    
    requestlable.textColor = [UIColor whiteColor];
    [notificview addSubview:requestlable];
    [notificview addSubview:amountlabel];
    [notificview addSubview:amountvalue];
    [doneview addSubview:notificview];
}
-(void)stoploadingview {
    [loadingview stopAnimating];
    [loadingview removeFromSuperview];
    [loadingbgview removeFromSuperview];
}
-(void)viewDidAppear:(BOOL)animated {
    //for testing only value 0.01
    //chargingvalue = @"0.1";
    
    NSLog(@"show price %@", [defaults objectForKey:@"onetimeprice"]);
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"scan.view"];
    if(chargingvalue == NULL) {
        chargingvalue = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"onetimeprice"]];
    }
    if ([chargingvalue rangeOfString:@"."].location == NSNotFound) {
        valuetoGWST = [NSString stringWithFormat:@"%@00", chargingvalue];
        chargingvalue = [NSString stringWithFormat:@"%@.00", chargingvalue];
    } else {
        valuetoGWST = [chargingvalue stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
    NSLog(@"show size %@, charge value %@", chargingvalue, valuetoGWST);
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    NSString *theString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[chargingvalue doubleValue]]];
    notificelabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, curwidth-50, 60)];
    notificelabel.backgroundColor = [UIColor clearColor];
    notificelabel.text = [NSString stringWithFormat:@"HK$ %@", theString];
    notificelabel.textAlignment = NSTextAlignmentCenter;
    notificelabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:58];
    notificelabel.textColor = [UIColor colorWithWhite:0.98 alpha:1];
    notificelabel.adjustsFontSizeToFitWidth = YES;
    [topview addSubview:notificelabel];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self qrcamfnt];
    }
    
    //[self getonetimeqrcode];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelpage:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)pencanpage:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)searchqr:(id)sender {
    NSString *receivedqr = sender;
    [info_view removeFromSuperview];
    [notificelabel removeFromSuperview];
    NSLog(@"received %@", receivedqr);
    foundqr = 0;
    [self performSelectorOnMainThread:@selector(senttoAlipay:) withObject:receivedqr waitUntilDone:YES];
}

-(IBAction)getonetimeqrcode:(id)sender {
    [self loadingview];
    UIButton *button = (UIButton *)sender;
    NSLog(@"show tag %ld", (long)[button tag]);
    if([button tag] == 0) {
        onetime_network = @"ALIPAY";
    } else if ([button tag] == 1) {
        onetime_network = @"WECHAT";
    } else if ([button tag] == 2) {
        onetime_network = @"CUP";
    }
    NSLog(@"The token %@", [defaults objectForKey:@"signature_secret"]);
    //NSString *acquireqrcodeurl = @"https://gateway.pa-sys.com/v1.0/offline/115e1da8-8d8a-4f9b-a8a8-302f866e4a95/acquire/qrcode";
    genmer_ref = [NSString stringWithFormat:@"TEST1_%.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *postosignqr = [NSString stringWithFormat:@"amount=%@&currency=HKD&descriptor=misc&merchant_reference=%@&network=%@&token=%@%@", chargingvalue, genmer_ref, onetime_network, [defaults objectForKey:@"signtoken"], [defaults objectForKey:@"signature_secret"]];
    [self performSelectorOnMainThread:@selector(createSHA512:) withObject:postosignqr waitUntilDone:YES];
    
    NSString *posttoacquire = [NSString stringWithFormat:@"amount=%@&currency=HKD&descriptor=misc&merchant_reference=%@&network=%@&sign=%@&token=%@",chargingvalue, genmer_ref,onetime_network, signstring,[defaults objectForKey:@"signtoken"]];
    
    NSData *postQRData = [posttoacquire dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postQRlength = [NSString stringWithFormat:@"%lu",(unsigned long)[posttoacquire length]];
    NSMutableURLRequest *QRrequests = [[NSMutableURLRequest alloc] init];
    
    [QRrequests setURL:[NSURL URLWithString:acquireqrcodeurl]];
    [QRrequests setHTTPMethod:@"POST"];
    [QRrequests setValue:postQRlength forHTTPHeaderField:@"Content-Length"];
    [QRrequests setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [QRrequests setHTTPBody:postQRData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:QRrequests completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(response &&! error) {
            NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"return log %@", responsestring);
            NSData *jsondata = [responsestring dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:jsondata options:0 error:nil];
            NSLog(@"the output %@", json);
            NSString *resultresponse = [[json objectForKey:@"response"] objectForKey:@"code"];
            if ([resultresponse integerValue] == 200) {
                NSString *showqring = [[json objectForKey:@"payload"] objectForKey:@"qr_code_string"];
                [self performSelectorOnMainThread:@selector(showqrcode:) withObject:showqring waitUntilDone:NO];
            }
        }
    }];
    [task resume];
    
}

-(IBAction)senttoAlipay:(id)sender {
    NSString *jsonmisc = @"{\"secondary_merchant_name\":\"Lotte\",\"secondary_merchant_id\":\"123\",\"secondary_merchant_industry\":\"5812\"}";
    //genmer_ref = [NSString stringWithFormat:@"%@-%.0f", [defaults objectForKey:@"MerchID"], [[NSDate date] timeIntervalSince1970]];
    if (![defaults objectForKey:@"transaction_remark"]) {
        posttosignst = [NSString stringWithFormat:@"amount=%@&bar_code=%@&currency=HKD&location=%@&product=unknown+misc&token=%@%@", chargingvalue, sender, [defaults objectForKey:@"updatelocation"],[defaults objectForKey:@"signtoken"], [defaults objectForKey:@"signature_secret"]];
    } else {
        posttosignst = [NSString stringWithFormat:@"amount=%@&bar_code=%@&currency=HKD&location=%@&product=unknown+misc&remark=%@&token=%@%@", chargingvalue, sender, [defaults objectForKey:@"updatelocation"],[defaults objectForKey:@"transaction_remark"],[defaults objectForKey:@"signtoken"], [defaults objectForKey:@"signature_secret"]];
    }
    NSLog(@"post to sha512, %@", posttosignst);
    [self performSelectorOnMainThread:@selector(createSHA512:) withObject:posttosignst waitUntilDone:YES];
    if(![defaults objectForKey:@"transaction_remark"]) {
        posttov3st = [NSString stringWithFormat:@"amount=%@&bar_code=%@&currency=HKD&location=%@&product=unknown+misc&sign=%@&token=%@", chargingvalue, sender,[defaults objectForKey:@"updatelocation"], signstring,[defaults objectForKey:@"signtoken"]];
    } else {
        posttov3st = [NSString stringWithFormat:@"amount=%@&bar_code=%@&currency=HKD&location=%@&product=unknown+misc&remark=%@&sign=%@&token=%@", chargingvalue, sender,[defaults objectForKey:@"updatelocation"], [defaults objectForKey:@"transaction_remark"], signstring,[defaults objectForKey:@"signtoken"]];
        [defaults removeObjectForKey:@"transaction_remark"];
    }
    NSData *miscdata = [jsonmisc dataUsingEncoding:NSUTF8StringEncoding];
    NSString *inputdata = [[NSString alloc] initWithData:miscdata encoding:NSUTF8StringEncoding];
    NSLog(@"data to sting %@", posttov3st);
    randstr = [NSString stringWithFormat:@"sR%i",arc4random()%100000-1];
    NSString *poststring = [NSString stringWithFormat:@"partner=2088621887384791&alipay_seller_id=2088621887384791&buyer_identity_code=%@&trans_name=iphonex&trans_amount=%@&extend_info=%@&partner_trans_id=%@", sender, chargingvalue,inputdata,randstr];
    NSData *postData = [posttov3st dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postlength = [NSString stringWithFormat:@"%lu",(unsigned long)[poststring length]];
    NSMutableURLRequest *requests = [[NSMutableURLRequest alloc] init];
    [requests setURL:[NSURL URLWithString:requesturl]];
    [requests setHTTPMethod:@"POST"];
    [requests setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [requests setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requests setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requests completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(response &&! error) {
            NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"return log %@", responsestring);
            NSData *jsondata = [responsestring dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:jsondata options:0 error:nil];
            NSString *resultresponse = [[json objectForKey:@"response"] objectForKey:@"code"];
            if ([resultresponse integerValue] == 400 || [resultresponse integerValue] == 500) {
                self->resultmessage = @"Error on payload";
            } else {
                self->resultmessage = [[json objectForKey:@"payload"] objectForKey:@"message"];
            }
            
            if([[json objectForKey:@"payload"] count] > 0) {
                NSLog(@"have payload");
                self->request_reference = [[json objectForKey:@"payload"] objectForKey:@"request_reference"];
            } else {
                NSLog(@"no payload");
            }
            
            //NSLog(@"Test Response %@", self->resultmessage);
            if([resultresponse integerValue] == 200) {
                if ([self->resultmessage isEqualToString:@"wait_buyer_action"]) {
                    NSLog(@"wait trend");
                    [self performSelectorOnMainThread:@selector(penReading) withObject:json waitUntilDone:NO];
                } else {
                    NSLog(@"success trend");
                    [self performSelectorOnMainThread:@selector(stopReading) withObject:json waitUntilDone:NO];
                }
            } else {
                if ([self->resultmessage isEqualToString:@"wait_buyer_action"]) {
                    NSLog(@"wait trend");
                    [self performSelectorOnMainThread:@selector(penReading) withObject:json waitUntilDone:NO];
                } else {
                    NSLog(@"error trend");
                    [self performSelectorOnMainThread:@selector(errReading) withObject:json waitUntilDone:NO];
                }
            }
        } else {
            NSLog(@"Fail: %@", error);
        }
    }];
    [task resume];
    
    
    //if([sender isEqualToString:@"9901c8ec3f3fc11e1da76ac4d8f70f02ff89b31c"]) {
    //    foundqr = 1;
    //} else {
    //    foundqr = 0;
    //}
}

-(IBAction)queryAliPay:(id)sender {
    
    NSURL *queryurl = [NSURL URLWithString:querystring];
    //NSString *postqueryst = [NSString stringWithFormat:@"partner=2088621887384791&partner_trans_id=%@", randstr];
    NSString *postv3queryst = [NSString stringWithFormat:@"token=%@&request_reference=%@", [defaults objectForKey:@"signtoken"], request_reference];
    NSData *postData = [postv3queryst dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postlength = [NSString stringWithFormat:@"%lu",(unsigned long)[postv3queryst length]];
    NSMutableURLRequest *requests = [[NSMutableURLRequest alloc] init];
    [requests setURL:queryurl];
    [requests setHTTPMethod:@"POST"];
    [requests setValue:postlength forHTTPHeaderField:@"Content-Length"];
    [requests setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requests setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requests completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(response &&! error) {
            NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"return log %@", responsestring);
            NSData *jsondata = [responsestring dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:jsondata options:0 error:nil];
            NSString *resultresponse = [[json objectForKey:@"response"] objectForKey:@"code"];
            
            NSLog(@"%@", resultresponse);
            if([resultresponse intValue] == 200) {
                self->request_reference = [[json objectForKey:@"payload"] objectForKey:@"request_reference"];
                NSString *payloadresponse = [[json objectForKey:@"payload"] objectForKey:@"status"];
                
                if([payloadresponse isEqualToString:@"TRADE_CLOSED"]) {
                    [self performSelectorOnMainThread:@selector(errReading) withObject:json waitUntilDone:NO];
                } else if([payloadresponse isEqualToString:@"TRADE_SUCCESS"]){
                    [self performSelectorOnMainThread:@selector(stopReading) withObject:json waitUntilDone:NO];
                } else if ([payloadresponse isEqualToString:@"WAIT_BUYER_PAY"]) {
                    [self performSelectorOnMainThread:@selector(penReading) withObject:json waitUntilDone:NO];
                }else {
                    [self performSelectorOnMainThread:@selector(penReading) withObject:json waitUntilDone:NO];
                }
            } else {
                [self performSelectorOnMainThread:@selector(errReading) withObject:json waitUntilDone:NO];
            }
            /*
            if([resultresponse isEqualToString:@"TRADE_CLOSED"]) {
                [self performSelectorOnMainThread:@selector(errReading) withObject:json waitUntilDone:NO];
            }else if ([resultresponse isEqualToString:@"SUCCESS"]) {
                
                [self performSelectorOnMainThread:@selector(stopReading) withObject:json waitUntilDone:NO];
            } else {
                
                [self performSelectorOnMainThread:@selector(penReading) withObject:json waitUntilDone:NO];
            }*/
        } else {
            NSLog(@"Fail: %@", error);
        }
    }];
    [task resume];
    
}

-(IBAction)showqrcode:(id)sender {
    [self stoploadingview];
    [bottomview removeFromSuperview];
    capturesession = nil;
    //[videoPreviewLayer removeFromSuperlayer];
    [substitle removeFromSuperview];
    [thecamview removeFromSuperview];
    [companyname removeFromSuperview];
    [invname removeFromSuperview];
    [doneview removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    doneview = [[UIView alloc] initWithFrame:CGRectMake(0, upperbar.frame.size.height, curwidth, curheigh-upperbar.frame.size.height)];
    doneview.backgroundColor = [UIColor whiteColor];
    NSLog(@"show qrcode %@", sender);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    NSString *theString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[chargingvalue doubleValue]]];
    
    UILabel *showqrvalue = [[UILabel alloc] init];
    showqrvalue.frame = CGRectMake(20, doneview.frame.size.height/8, doneview.frame.size.width-40, 40);
    showqrvalue.textAlignment = NSTextAlignmentCenter;
    showqrvalue.font = [UIFont systemFontOfSize:38];
    showqrvalue.text = [NSString stringWithFormat:@"HKD %@", theString];
    
    UILabel *showinstruction = [[UILabel alloc] init];
    showinstruction.frame = CGRectMake(10, doneview.frame.size.height/2-(curwidth-20)/2 + curwidth-10, curwidth-20, 26);
    showinstruction.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    showinstruction.font = [UIFont systemFontOfSize:24];
    showinstruction.adjustsFontSizeToFitWidth = YES;
    showinstruction.textAlignment = NSTextAlignmentCenter;
    showinstruction.text = @"SHOW THIS QRCODE TO CUSTOMER AND SCAN IT";
    NSData *stringdata = [sender dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFiler = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFiler setValue:stringdata forKey:@"inputMessage"];
    [qrFiler setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFiler.outputImage;
    float scaleX = curwidth/ qrImage.extent.size.width;
    float scaleY = curwidth/ qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    showqrview = [[UIImageView alloc] initWithFrame:CGRectMake(10, doneview.frame.size.height/2-(curwidth-20)/2, curwidth-20, curwidth-20)];
    showqrview.image = [UIImage imageWithCIImage:qrImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    [doneview addSubview:showqrvalue];
    
    [doneview addSubview:showqrview];
    [doneview addSubview:showinstruction];
    [self.view addSubview:doneview];
    
}
-(void)stopReading {
    //[capturesession stopRunning];
    [self stoploadingview];
    capturesession = nil;
    //[videoPreviewLayer removeFromSuperlayer];
    [substitle removeFromSuperview];
    [thecamview removeFromSuperview];
    [invname removeFromSuperview];
    [companyname removeFromSuperview];
    [bottomview removeFromSuperview];
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    if ([defaults objectForKey:@"transitionstatus"] == NULL) {
        [defaults setObject:@"success" forKey:@"transitionstatus"];
        [defaults setObject:chargingvalue forKey:@"transitionamount"];
        [defaults setObject:newDateString forKey:@"transitiontime"];
    } else {
        [defaults setObject:[NSString stringWithFormat:@"success,%@", [defaults objectForKey:@"transitionstatus"]] forKey:@"transitionstatus"];
        [defaults setObject:[NSString stringWithFormat:@"%@,%@", chargingvalue, [defaults objectForKey:@"transitionamount"]] forKey:@"transitionamount"];
        [defaults setObject:[NSString stringWithFormat:@"%@,%@",newDateString, [defaults objectForKey:@"transitiontime"]] forKey:@"transitiontime"];
    }
    NSLog(@"goto NS %@", [defaults objectForKey:@"transitionstatus"]);
    
    UILabel *showqr = [[UILabel alloc] initWithFrame:CGRectMake(2, 75, curwidth-4, 15)];
    showqr.textColor = [UIColor whiteColor];
    showqr.textAlignment = NSTextAlignmentCenter;
    showqr.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    showqr.adjustsFontSizeToFitWidth = YES;
    showqr.text = [NSString stringWithFormat:@"Transition code: %@", scanqrcode];
    [self.view addSubview:showqr];
    
    UILabel *merchlab = [[UILabel alloc] initWithFrame:CGRectMake(25, 75, curwidth/3-25, 35)];
    merchlab.textAlignment = NSTextAlignmentLeft;
    merchlab.textColor = [UIColor whiteColor];
    merchlab.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:19];
    UILabel *merchname = [[UILabel alloc] initWithFrame:CGRectMake(curwidth/3, 75, 2*curwidth/3-5, 35)];
    merchname.textAlignment = NSTextAlignmentLeft;
    merchname.textColor = [UIColor whiteColor];
    merchname.font = [UIFont systemFontOfSize:33 weight:UIFontWeightMedium];
    UILabel *orderlab = [[UILabel alloc] initWithFrame:CGRectMake(25, 120, curwidth/3-25, 35)];
    orderlab.textAlignment = NSTextAlignmentLeft;
    orderlab.textColor = [UIColor whiteColor];
    orderlab.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:19];
    UILabel *ordername = [[UILabel alloc] initWithFrame:CGRectMake(curwidth/3, 120, 2*curwidth/3-5, 35)];
    ordername.textAlignment = NSTextAlignmentLeft;
    ordername.textColor = [UIColor whiteColor];
    ordername.font = [UIFont systemFontOfSize:33 weight:UIFontWeightMedium];
    UILabel *amountlab = [[UILabel alloc] initWithFrame:CGRectMake(25, 165, curwidth/3-25, 35)];
    amountlab.textAlignment = NSTextAlignmentLeft;
    amountlab.textColor = [UIColor whiteColor];
    amountlab.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:19];
    UILabel *amountname = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, curwidth, 35)];
    amountname.textAlignment = NSTextAlignmentCenter;
    amountname.textColor = [UIColor whiteColor];
    amountname.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:33];
    
    merchlab.text = @"Merchant:";
    orderlab.text = @"Order:";
    amountlab.text =@"Amount:";
    merchname.text = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"merchant_name"]];
    ordername.text = randstr;
    amountname.text = [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:@"usercurrency"], chargingvalue];
    [doneview removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    
    doneview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-0)];
    doneview.backgroundColor = [UIColor colorWithRed:0.51 green:0.85 blue:0.63 alpha:1];
    [self.view addSubview:doneview];
    
    //[doneview addSubview:merchlab];
    //[doneview addSubview:merchname];
    //[doneview addSubview:orderlab];
    //[doneview addSubview:ordername];
    //[doneview addSubview:amountlab];
    [doneview addSubview:amountname];
    
    noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, curwidth, 30)];
    noticelabel.backgroundColor = [UIColor clearColor];
    noticelabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    noticelabel.text = NSLocalizedString( @"Payment Received", nil);
    noticelabel.textAlignment = NSTextAlignmentCenter;
    noticelabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightThin];
    UIImage *successimg = [UIImage imageNamed:@"success.png"];
    UIImageView *notifyview = [[UIImageView alloc] initWithImage:successimg];
    notifyview.frame = CGRectMake(doneview.bounds.size.width/2-45, 60, 90, 90);
    
    UILabel *labReceive = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, notificview.frame.size.width-10, 19)];
    labReceive.textColor = [UIColor whiteColor];
    labReceive.text = @"Received";
    labReceive.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
    labReceive.textAlignment = NSTextAlignmentLeft;
    
    CALayer* layer = [labReceive layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height+5,layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor whiteColor].CGColor];
    [layer addSublayer:bottomBorder];
    
    [notificview addSubview:labReceive];
    
    [cancelbutton removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    [doneview addSubview:noticelabel];
    [doneview addSubview:notifyview];
    
    bottomcancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomcancelbutton.frame = CGRectMake(20, curheigh-80, curwidth-40, 50);
    [bottomcancelbutton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [bottomcancelbutton setBackgroundColor:[UIColor whiteColor]];
    [bottomcancelbutton setTitleColor:[UIColor colorWithRed:0.51 green:0.85 blue:0.63 alpha:1] forState:UIControlStateNormal];
    bottomcancelbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    bottomcancelbutton.layer.borderWidth = 0.5f;
    bottomcancelbutton.layer.cornerRadius = 25.0f;
    [bottomcancelbutton addTarget:self action:@selector(closeview:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomcancelbutton];
    
    
    emailnotification = [UIButton buttonWithType:UIButtonTypeCustom];
    emailnotification.frame = CGRectMake(20, curheigh-160, curwidth-40, 50);
    [emailnotification setTitle:@"Email Receipt" forState:UIControlStateNormal];
    [emailnotification setBackgroundColor:[UIColor whiteColor]];
    [emailnotification setTitleColor:[UIColor colorWithRed:0.51 green:0.85 blue:0.63 alpha:1] forState:UIControlStateNormal];
    emailnotification.layer.borderColor = [UIColor whiteColor].CGColor;
    emailnotification.layer.borderWidth = 0.5f;
    emailnotification.layer.cornerRadius = 25.0f;
    [emailnotification addTarget:self action:@selector(submitemail:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:emailnotification];
    
    //startbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    //startbutton.frame = CGRectMake(0, 0, 300, 55);
    //startbutton.backgroundColor = [UIColor colorWithRed:0.94 green:0.68 blue:0.13 alpha:1];
    //[startbutton setTitle:@"Scan Again" forState:UIControlStateNormal];
    //[startbutton addTarget:self action:@selector(restartReading) forControlEvents:UIControlEventTouchUpInside];
    //[actionview addSubview:startbutton];
}
-(void)penReading {
    //[capturesession stopRunning];
    [self stoploadingview];
    [bottomview removeFromSuperview];
    capturesession = nil;
    //[videoPreviewLayer removeFromSuperlayer];
    [substitle removeFromSuperview];
    [thecamview removeFromSuperview];
    [companyname removeFromSuperview];
    [invname removeFromSuperview];
    [doneview removeFromSuperview];
    //NSDate * now = [NSDate date];
    
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    //NSString *newDateString = [outputFormatter stringFromDate:now];
    
    doneview = [[UIView alloc] initWithFrame:CGRectMake(0, 70, curwidth, curwidth/2+curheigh/2-70)];
    doneview.backgroundColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1];
    
    noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, curwidth, 30)];
    noticelabel.backgroundColor = [UIColor clearColor];
    noticelabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    noticelabel.text = NSLocalizedString(@"Payment Processing", nil);
    noticelabel.textAlignment = NSTextAlignmentCenter;
    noticelabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightThin];
    
    UILabel *actionlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, doneview.frame.size.height-30, curwidth-20, 25)];
    actionlabel.textColor = [UIColor whiteColor];
    actionlabel.text = NSLocalizedString(@"Please inform customer to input the password on his/her Alipay App", nil);
    actionlabel.textAlignment = NSTextAlignmentCenter;
    actionlabel.adjustsFontSizeToFitWidth = YES;
    actionlabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightLight];
    
    UIImage *successimg = [UIImage imageNamed:@"waiting.png"];
    UIImageView *notifyview = [[UIImageView alloc] initWithImage:successimg];
    notifyview.frame = CGRectMake(doneview.bounds.size.width/2-45, 60, 90, 90);
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI *2.0 ];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 65535;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [notifyview.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    UILabel *theamount = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, curwidth-20, 35)];
    theamount.text = [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:@"usercurrency"], chargingvalue];
    theamount.textAlignment = NSTextAlignmentCenter;
    theamount.textColor = [UIColor whiteColor];
    [theamount adjustsFontSizeToFitWidth];
    theamount.font = [UIFont fontWithName:@"Signika-Regular" size:33];
    [doneview addSubview:theamount];
    
    [cancelbutton removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    [doneview addSubview:noticelabel];
    [doneview addSubview:notifyview];
    [doneview addSubview:actionlabel];
    
    [cancelbutton removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    [self.view addSubview:doneview];
    
    bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, curwidth/2+curheigh/2, curwidth, curheigh-curwidth/2-curheigh/2)];
    bottomview.backgroundColor = [UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1];
    
    bottomcancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomcancelbutton.frame = CGRectMake(20, 20, curwidth-40, 50);
    [bottomcancelbutton setTitle:NSLocalizedString(@"Retry and Close", nil) forState:UIControlStateNormal];
    [bottomcancelbutton setBackgroundColor:[UIColor whiteColor]];
    [bottomcancelbutton setTitleColor:[UIColor colorWithRed:0.38 green:0.66 blue:0.87 alpha:1] forState:UIControlStateNormal];
    bottomcancelbutton.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    bottomcancelbutton.layer.borderWidth = 0.5f;
    bottomcancelbutton.layer.cornerRadius = 25.0f;
    [bottomcancelbutton addTarget:self action:@selector(cancelpage:) forControlEvents:UIControlEventTouchUpInside];
    //[bottomcancelbutton addTarget:self action:@selector(queryAliPay:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomview addSubview:bottomcancelbutton];
    [self.view addSubview:bottomview];
    
    //[self performSelector:@selector(queryAliPay:) withObject:nil afterDelay:5];
}

-(void)errReading {
    //[capturesession stopRunning];
    [self stoploadingview];
    [bottomview removeFromSuperview];
    capturesession = nil;
    //[videoPreviewLayer removeFromSuperlayer];
    [substitle removeFromSuperview];
    [thecamview removeFromSuperview];
    [companyname removeFromSuperview];
    [invname removeFromSuperview];
    [bottomcancelbutton removeFromSuperview];
    
    closebutton = [[UIButton alloc] initWithFrame:CGRectMake(curwidth-83, 35, 80, 20)];
    closebutton.backgroundColor = [UIColor clearColor];
    [closebutton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [closebutton setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
    [closebutton setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [closebutton addTarget:self action:@selector(closeview:) forControlEvents:UIControlEventTouchUpInside];
    [upperbar addSubview:closebutton];
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    if ([defaults objectForKey:@"transitionstatus"] == NULL) {
        [defaults setObject:@"fail" forKey:@"transitionstatus"];
        [defaults setObject:chargingvalue forKey:@"transitionamount"];
        [defaults setObject:newDateString forKey:@"transitiontime"];
    } else {
        [defaults setObject:[NSString stringWithFormat:@"fail,%@", [defaults objectForKey:@"transitionstatus"]] forKey:@"transitionstatus"];
        [defaults setObject:[NSString stringWithFormat:@"%@,%@", chargingvalue, [defaults objectForKey:@"transitionamount"]] forKey:@"transitionamount"];
        [defaults setObject:[NSString stringWithFormat:@"%@,%@", newDateString, [defaults objectForKey:@"transitiontime"]] forKey:@"transitiontime"];
    }
    
    NSLog(@"no track");
    doneview = [[UIView alloc] initWithFrame:CGRectMake(0, 70, curwidth, curwidth/2+curheigh/2-70)];
    doneview.backgroundColor = [UIColor colorWithRed:0.90 green:0.47 blue:0.53 alpha:1];
    
    [cancelbutton removeFromSuperview];
    [self.view addSubview:doneview];
    //[self notificview_fun];
    
    noticelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, curwidth, 30)];
    noticelabel.backgroundColor = [UIColor clearColor];
    noticelabel.textColor = [UIColor whiteColor];
    noticelabel.text = NSLocalizedString(@"Payment Declined", nil);
    noticelabel.textAlignment = NSTextAlignmentCenter;
    noticelabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:27.f];
    UIImage *successimg = [UIImage imageNamed:@"block.png"];
    UIImageView *notifyview = [[UIImageView alloc] initWithImage:successimg];
    notifyview.frame = CGRectMake(doneview.bounds.size.width/2-45, 60, 90, 90);
    
    UILabel *labReceive = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, notificview.frame.size.width-10, 19)];
    labReceive.textColor = [UIColor whiteColor];
    labReceive.text = @"Transcation Details";
    labReceive.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
    labReceive.textAlignment = NSTextAlignmentLeft;
    
    CALayer* layer = [labReceive layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height+5,layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor whiteColor].CGColor];
    [layer addSublayer:bottomBorder];
    
    [notificview addSubview:labReceive];
    
    UILabel *theamount = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, curwidth-20, 35)];
    theamount.text = [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:@"usercurrency"], chargingvalue];
    theamount.textAlignment = NSTextAlignmentCenter;
    theamount.textColor = [UIColor whiteColor];
    [theamount adjustsFontSizeToFitWidth];
    theamount.font = [UIFont fontWithName:@"Signika-Regular" size:33];
    [doneview addSubview:theamount];
    
    [doneview addSubview:noticelabel];
    [doneview addSubview:notifyview];
    
    bottomcancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomcancelbutton.frame = CGRectMake(10, 80, curwidth-20, 40);
    [bottomcancelbutton setTitle:@"Close" forState:UIControlStateNormal];
    [bottomcancelbutton setBackgroundColor:[UIColor clearColor]];
    [bottomcancelbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bottomcancelbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    bottomcancelbutton.layer.borderWidth = 0.5f;
    bottomcancelbutton.layer.cornerRadius = 20.0f;
    [bottomcancelbutton addTarget:self action:@selector(cancelpage:) forControlEvents:UIControlEventTouchUpInside];
    
    rescanbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    rescanbutton.frame = CGRectMake(20, 20, curwidth-40, 50);
    [rescanbutton setTitle:NSLocalizedString(@"RESCAN", nil) forState:UIControlStateNormal];
    [rescanbutton setBackgroundColor:[UIColor whiteColor]];
    [rescanbutton setTitleColor:[UIColor colorWithRed:0.90 green:0.47 blue:0.53 alpha:1] forState:UIControlStateNormal];
    rescanbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    rescanbutton.layer.borderWidth = 0.5f;
    rescanbutton.layer.cornerRadius = 25.0f;
    
    [rescanbutton addTarget:self action:@selector(restartReading) forControlEvents:UIControlEventTouchUpInside];
    bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, curwidth/2+curheigh/2, curwidth, curheigh-curwidth/2-curheigh/2)];
    bottomview.backgroundColor = [UIColor colorWithRed:0.90 green:0.47 blue:0.53 alpha:1];
    [bottomview addSubview:rescanbutton];
    [self.view addSubview:bottomview];
}

-(void)restartReading {
    
    [self performSelector:@selector(createview) withObject:nil afterDelay:0];
    [self performSelector:@selector(qrcamfnt) withObject:nil afterDelay:0];
}

-(BOOL)startReading {
    return YES;
}

-(IBAction)generateqr:(id)sender {
    [capturesession stopRunning];
    capturesession = nil;
    [videoPreviewLayer removeFromSuperlayer];
    [showqrview removeFromSuperview];
    [info_view removeFromSuperview];
    [companyname removeFromSuperview];
    [invname removeFromSuperview];
    
    UIView *scanbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    scanbg.backgroundColor = [UIColor colorWithRed:0.21 green:0.48 blue:0.76 alpha:1];
    [self.view addSubview:scanbg];
    bottomcancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomcancelbutton.frame = CGRectMake(10, curheigh-80, curwidth-20, 40);
    [bottomcancelbutton setTitle:@"Close" forState:UIControlStateNormal];
    [bottomcancelbutton setBackgroundColor:[UIColor clearColor]];
    [bottomcancelbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bottomcancelbutton.layer.borderColor = [UIColor whiteColor].CGColor;
    bottomcancelbutton.layer.borderWidth = 0.5f;
    bottomcancelbutton.layer.cornerRadius = 5.0f;
    [bottomcancelbutton addTarget:self action:@selector(cancelpage:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *qrstring = [NSString stringWithFormat:@"https://www.paypal.me/atroposjr/%@HKD", chargingvalue];
    NSData *stringdata = [qrstring dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFiler = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFiler setValue:stringdata forKey:@"inputMessage"];
    [qrFiler setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFiler.outputImage;
    float scaleX = curwidth/ qrImage.extent.size.width;
    float scaleY = curwidth/ qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    showqrview = [[UIImageView alloc] initWithFrame:CGRectMake(0, curheigh/2-curwidth/2, curwidth, curwidth)];
    showqrview.image = [UIImage imageWithCIImage:qrImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    UIView *infobar = [[UIView alloc] initWithFrame:CGRectMake(0, curwidth, curwidth, 60)];
    infobar.backgroundColor = [UIColor colorWithRed:0.02 green:0.55 blue:0.86 alpha:0.8];
    
    UILabel *info_label = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, curwidth-10, 30)];
    info_label.backgroundColor = [UIColor clearColor];
    info_label.text = [NSString stringWithFormat:@"Scan Alipay Code to pay"];
    info_label.textAlignment = NSTextAlignmentCenter;
    info_label.textColor = [UIColor whiteColor];
    info_label.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
    
    [self.view addSubview:infobar];
    [infobar addSubview:info_label];
    [self.view addSubview:showqrview];
    [self.view addSubview:bottomcancelbutton];
}
-(NSString *)createSHA512:(NSString *)string
{
    NSString *escapedString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    //NSLog(@"ursl string %@", escapedString);
    const char *cstr = [escapedString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (int)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    signstring = output;
    //NSLog(@"the sha 512 string: %@", output);
    return output;
}

-(IBAction)submitemail:(id)sender {
    finishview = [self.storyboard instantiateViewControllerWithIdentifier:@"finishemailview"];
    
    [self.navigationController pushViewController:finishview animated:YES];
}
-(IBAction)closeview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)backview:(id)sender {
    [self popoverPresentationController];
}
-(void)loadingBeep {
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    [audioPlayer prepareToPlay];
}

+(void)rotationLayerInf:(CALayer *)layer {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.duration = 0.7f;
    rotation.repeatCount = HUGE_VALF;
    [layer removeAllAnimations];
    [layer addAnimation:rotation forKey:@"Spin"];
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
