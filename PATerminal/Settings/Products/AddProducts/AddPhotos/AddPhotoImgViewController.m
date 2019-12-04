//
//  AddPhotoImgViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/01.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "AddPhotoImgViewController.h"
#import <CoreImage/CoreImage.h>

@interface AddPhotoImgViewController ()

@end

@implementation AddPhotoImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mainview = [[UIImageView alloc] init];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    self.navigationController.navigationBar.hidden = NO;
    imageData = [[NSData alloc] init];
    standarddefault = [NSUserDefaults standardUserDefaults];
    mainview.frame = CGRectMake(0, 0, curwidth, curheigh-80);
    mainview.contentMode = UIViewContentModeScaleAspectFit;
    bottomview = [[UIView alloc] init];
    bottomview.frame = CGRectMake(0, curheigh-80, curwidth, 80);
    bottomview.backgroundColor = [UIColor darkGrayColor];
    swipetolibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    swipetolibrary.frame = CGRectMake(0, 0, curwidth/2, 80);
    [swipetolibrary setTitle:@"From library" forState:UIControlStateNormal];
    [swipetolibrary addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    takephotobutton = [UIButton buttonWithType:UIButtonTypeCustom];
    takephotobutton.frame = CGRectMake(curwidth/2, 0, curwidth/2, 80);
    [takephotobutton setTitle:@"Take Photo" forState:UIControlStateNormal];
    [takephotobutton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomview addSubview:takephotobutton];
    [bottomview addSubview:swipetolibrary];
    /*
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
                [catureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeEAN13Code, nil]];
                videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:capturesession];
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                videoPreviewLayer.frame = mainview.bounds;
                [mainview.layer addSublayer:videoPreviewLayer];
                [capturesession startRunning];
            }
        }
    }
     */
    [self.view addSubview:mainview];
    [self.view addSubview:bottomview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
-(IBAction)selectPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    mainview.image = chosenImage;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.8);
    [standarddefault setObject:imageData forKey:@"selected_image"];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
