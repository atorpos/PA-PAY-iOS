//
//  TodayViewController.m
//  PATerminal_widget
//
//  Created by oskar wong on 30/7/2019.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <CoreImage/CoreImage.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController
@synthesize thetotal;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
    standardUser = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.paymentasia.papay"];
    id value = [standardUser valueForKey:@"qrcodestring"];
    id sumvalue = [standardUser valueForKey:@"update_amount"];
    NSLog(@"testing %@, %@",value, sumvalue);
    thetotal.text = [NSString stringWithFormat:@"$ %.2f", [sumvalue doubleValue]];
    [thetotal setNeedsDisplay];
//    if([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) {
//        [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
//    } else {
//        self.preferredContentSize = CGSizeMake(0, 320);
//    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    
    //NSLog(@"testing %@", [standardUser objectForKey:@"qrcodestring"]);
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

-(void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if(activeDisplayMode == NCWidgetDisplayModeExpanded) {
        NSLog(@"show the expandview");
        self.preferredContentSize = CGSizeMake(maxSize.width, 320.0);
        [self createQR];
//        UIImageView *theview = [[UIImageView alloc] init];
//        theview.frame = CGRectMake(self.view.frame.size.width/2-100, 110, 200, 200);
//        UIImage *qrimage =[UIImage imageNamed:@"dummy_qr.png"];
//        [theview setImage:qrimage];
//        [self.view addSubview:theview];
    } else if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = maxSize;
        NSLog(@"show the compact view");
        
    }
}
-(void)createQR {
    NSString *urlstring = [standardUser objectForKey:@"qrcodestring"];
    NSData *stringData = [urlstring dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter *qrfilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrfilter setValue:stringData forKey:@"inputMessage"];
    [qrfilter setValue:@"L" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCodeImage = qrfilter.outputImage;
    CGRect imagesize = CGRectIntegral(qrCodeImage.extent);
    CGSize outputsize = CGSizeMake(320,320);
    CIImage *imageResize = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputsize.width/CGRectGetWidth(imagesize), outputsize.height/CGRectGetHeight(imagesize))];
    
    
    UIImageView *showview = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 110, 200, 200)];
    UIImage *imageset = [[UIImage alloc] initWithCIImage:imageResize];
    
    [showview setImage:imageset];
    
    [self.view addSubview:showview];

}



@end
