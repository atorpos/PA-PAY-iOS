//
//  passiveViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/07.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "passiveViewController.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import "writefiles.h"

@interface passiveViewController ()

@end

@implementation passiveViewController
@synthesize stringvalue;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    defaults = [NSUserDefaults standardUserDefaults];
    
    /*
        http://gateway.lulu.pa-sys.com/paypal/payment?merchant_id=39&terminal_id=20&currency=HKD&amount=100&sign=23c4f5d822e972fa730d939582248dec6db9498a1436c5a1977e3d6e8e98f9be64be746296025b4c6269e9f67c5a2e9b72ff6ae0ce3b77296d4c214d5397b4f1
    */
    
    NSString *posttosignst = [NSString stringWithFormat:@"amount=%@&currency=HKD&merchant_id=%@&terminal_id=%@%@", stringvalue,[defaults objectForKey:@"merchantidinput"], [defaults objectForKey:@"terminalidinput"],[defaults objectForKey:@"signature_secret"]];
    NSLog(@"post to sha512, %@", posttosignst);
    [self performSelectorOnMainThread:@selector(createSHA512:) withObject:posttosignst waitUntilDone:YES];
    
    self.navigationItem.title = NSLocalizedString(@"Pay By PayPal", nil);
    UIView *scanbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    scanbg.backgroundColor = [UIColor colorWithRed:0.21 green:0.48 blue:0.76 alpha:1];
    [self.view addSubview:scanbg];
    NSLog(@"the receive value %@", stringvalue);
    //NSString *qrstring = [NSString stringWithFormat:@"https://www.paypal.me/atroposjr/%@HKD", stringvalue];
    NSString *qrstring = [NSString stringWithFormat:@"https://gateway.pa-sys.com/paypal/payment?amount=%@&currency=HKD&merchant_id=%@&terminal_id=%@&sign=%@", stringvalue,[defaults objectForKey:@"merchantidinput"], [defaults objectForKey:@"terminalidinput"], signstring];
    NSLog(@"paypal %@", qrstring);
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
    
    UIImageView *paybypaypalview = [[UIImageView alloc] initWithFrame:CGRectMake(10, curheigh/2-curwidth/2+curwidth+10, curwidth-20, 60)];
    paybypaypalview.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *imgpaypal = [UIImage imageNamed:@"PayPal_2014_logo"];
    [paybypaypalview setImage:imgpaypal];
    
    [self.view addSubview:paybypaypalview];
    [self.view addSubview:showqrview];
}
-(void)viewDidAppear:(BOOL)animated {
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"paypal.view"];
}
-(NSString *)createSHA512:(NSString *)string
{
    NSString *escapedString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"ursl string %@", escapedString);
    const char *cstr = [escapedString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (int)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    signstring = output;
    NSLog(@"the sha 512 string: %@", output);
    return output;
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
