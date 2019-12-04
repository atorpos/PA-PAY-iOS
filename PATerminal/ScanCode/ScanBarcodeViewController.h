//
//  ScanBarcodeViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@class writefiles;
@class HistoryDetailViewController;
@interface ScanBarcodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    AVCaptureSession *capturesession;
    CGFloat curwidth;
    CGFloat curheigh;
    UIImageView *imageview;
    NSString *scanqrcode;
    NSUserDefaults *standarddefault;
    writefiles *writefileclass;
    HistoryDetailViewController *historydetailview;
}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *capturesession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading;
-(void)stopReading;
@end
