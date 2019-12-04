//
//  AddPhotoImgViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/01.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AddPhotoImgViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate> {
    IBOutlet UIImageView *mainview;
    IBOutlet UIImagePickerController *imagecontroller;
    NSUserDefaults *standarddefault;
    CGFloat curwidth;
    CGFloat curheigh;
    AVCaptureSession *capturesession;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    UIView *bottomview;
    UIButton *takephotobutton;
    UIButton *swipetolibrary;
    NSData *imageData;
}
-(IBAction)takePhoto:(UIButton *)sender;
-(IBAction)selectPhoto:(UIButton *)sender;

@end
