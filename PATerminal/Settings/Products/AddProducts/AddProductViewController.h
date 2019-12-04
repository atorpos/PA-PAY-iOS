//
//  AddProductViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/17.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Product_info+CoreDataClass.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@class AddProductViewController;
@class AddPhotoImgViewController;
@class ScanBarcodeViewController;
@interface AddProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate> {
    UITableView *maintable;
    AddPhotoImgViewController *addphotoview;
    ScanBarcodeViewController *scanbarview;
    AddProductViewController *orgaddphoto;
    CGFloat curwidth;
    CGFloat curheigh;
    UITextField *inputnamefield;
    UITextField *skufield;
    UITextField *pricefield;
    UITextField *receivestock;
    NSUserDefaults *standarddefault;
    NSString *inputname;
    NSString *inputsku;
    NSString *inputprice;
    NSString *inputstock;
    NSData *inputimage;
    Product_info *productinfo;
    NSManagedObjectContext *context;
    NSManagedObject *newunit;
    NSManagedObjectModel *fetchcontext;
    UINavigationController *navcon;
    UIView *cameraview;
    UIImageView *imageView;
    UIImageView *scanView;
    AVCaptureSession *capturesession;
    NSString *scanqrcode;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *capturesession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (copy) NSString *typeofclick;

-(BOOL)startReading;
-(void)stopReading;
-(void)saveContext;
@end
