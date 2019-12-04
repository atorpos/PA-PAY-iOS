//
//  ScanBarcodeViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "ScanBarcodeViewController.h"
#import "writefiles.h"
#import "HistoryDetailViewController.h"
#import "services.pch"
@interface ScanBarcodeViewController ()

@end

@implementation ScanBarcodeViewController
@synthesize capturesession, videoPreviewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:NO];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh)];
    standarddefault = [NSUserDefaults standardUserDefaults];
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelpage:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    self.navigationController.navigationItem.title = @"Find receipt";
    [imageview addGestureRecognizer:swipeGesture];
    
    [self.view addSubview:imageview];
    
}

-(void)qrcamfnt {
    NSLog(@"run qr");
    //turn on the qr camera
    _isReading = NO;
    capturesession = nil;
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
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
                [catureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeCode39Mod43Code, nil]];
                videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:capturesession];
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                videoPreviewLayer.frame = imageview.bounds;
                [imageview.layer addSublayer:videoPreviewLayer];
                [capturesession startRunning];
            }
        }
    }
    
    [self.view addSubview:imageview];
    //end of QR cam
}
-(void)viewDidAppear:(BOOL)animated {
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"scanbarcode.view"];
    [self qrcamfnt];
}
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSLog(@"the code %@", [metadataObj stringValue]);
        scanqrcode = [metadataObj stringValue];
        [capturesession stopRunning];
        [self stopReading];
        /*
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] || [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode128Code]) {
            [capturesession stopRunning];
            //[self performSelectorOnMainThread:@selector(loadingview) withObject:nil waitUntilDone:NO];
            NSLog(@"%@", [metadataObj stringValue]);
            scanqrcode = [metadataObj stringValue];
            //[qrcodedeco performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            //[self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[self performSelectorOnMainThread:@selector(searchqr:) withObject:scanqrcode waitUntilDone:NO];
            _isReading = NO;
        }*/
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)startReading {
    
    return YES;
}
-(void)stopReading {
    capturesession = nil;
//    [standarddefault setObject:scanqrcode forKey:@"add_sku"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//       [self.navigationController popViewControllerAnimated:YES];
//    });
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self->historydetailview = [storyboard instantiateViewControllerWithIdentifier:@"historydetailview"];
        self->historydetailview.weblinkstring = [NSString stringWithFormat:@"%@/transaction-detail/?token=%@&request_reference=%@", PRODUCTION_MERCH_URl, [self->standarddefault objectForKey:@"signtoken"], self->scanqrcode];
        [self.navigationController pushViewController:self->historydetailview animated:YES];
    });
    
}
-(IBAction)cancelpage:(id)sender {
    NSLog(@"cancel page");
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
