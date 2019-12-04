//
//  ScanViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/13.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SERVICE.h"

@class writefiles;
@class FinishedViewController;
@interface ScanViewController : UIViewController <UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate> {
    IBOutlet UIButton *cancelbutton;
    FinishedViewController *finishview;
    UINavigationController *navcontroller;
    CGFloat curwidth;
    CGFloat curheigh;
    int foundqr;
    IBOutlet UIBarButtonItem *cancelsbtm;
    NSUserDefaults *defaults;
    AVCaptureSession *capturesession;
    NSString *scanqrcode;
    UIView *doneview;
    UILabel *noticelabel;
    UIButton *bottomcancelbutton;
    UIButton *rescanbutton;
    UIView *bottomview;
    UIView *topview;
    UIImageView *showqrview;
    UIButton *info_view;
    UILabel *notificelabel;
    UIImageView *scanlayoutview;
    NSString *valuetoGWST;
    UIView *thecamview;
    UIView *upperbar;
    UILabel *companyname;
    UILabel *invname;
    UIImage *scanlayoutimg;
    UIImageView *bgimage;
    NSString *requesturl;
    UIActivityIndicatorView *loadingview;
    UIView *loadingbgview;
    UIView *notificview;
    NSString *randstr;
    NSString *signstring;
    NSString *querystring;
    NSString *genmer_ref;
    UILabel *substitle;
    NSString *request_reference;
    UIButton *closebutton;
    NSString *resultmessage;
    writefiles *writefileclass;
    NSString *showonetimeqrcode;
    NSString *acquireqrcodeurl;
    NSString *onetime_network;
    NSString *posttosignst;
    NSString *posttov3st;
}

@property (copy) NSString *chargingvalue;

@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) IBOutlet UILabel *qrcodedeco;
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (nonatomic, strong) AVCaptureSession *capturesession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

-(BOOL)startReading;
-(void)stopReading;

@end
