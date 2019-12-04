//
//  ScanInvoiceViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 10/28/19.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "SERVICE.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanInvoiceViewController : UIViewController<UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    UIView *mainview;
    AVCaptureSession *capturesession;
    UIActivityIndicatorView *loadingview;
    NSString *scancode;
    UILabel *subtitle;
    UIImageView *scanlayoutview;
    UIView *thecamview;
    NSString *scanqrcode;
    UIImage *scanlayoutimg;
    
}
@property (nonatomic) BOOL isReading;
@property (copy) NSString *chargingvalue;
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (nonatomic, strong) AVCaptureSession *capturesession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

NS_ASSUME_NONNULL_END
