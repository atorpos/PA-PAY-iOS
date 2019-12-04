//
//  ScanInvoiceViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 10/28/19.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import "ScanInvoiceViewController.h"

@interface ScanInvoiceViewController ()

@end

@implementation ScanInvoiceViewController

@synthesize chargingvalue, imageview, capturesession, videoPreviewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    mainview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    mainview.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
//    self.navigationController.navigationBar.translucent = YES;
    [self createui];
    [self.view addSubview:mainview];
}

-(void)createui {
    thecamview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    thecamview.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.view addSubview:thecamview];
    [self qrcamfnt];
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
            
        }
    }
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
