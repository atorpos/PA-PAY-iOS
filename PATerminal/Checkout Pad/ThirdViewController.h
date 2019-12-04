//
//  ThirdViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Product_info+CoreDataClass.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class ScanViewController;
@class passiveViewController;
@class writefiles;
@interface ThirdViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate, UITextFieldDelegate> {
    UIColor *setcolor;
    UIView *mainview;
    UIView *upperview;
    UIView *bottomview;
    UIScrollView *muiltview;
    UITableView *tableview;
    CLLocationManager *locationManager;
    CGFloat curwidth;
    CGFloat curheigh;
    CGFloat uppheigh;
    CGFloat uppheigh_x;
    CGFloat uppheight_xr;
    CGFloat buttonheigh;
    CGFloat uppheigh_ipad;
    CGFloat paybutton_width;
    ScanViewController *scanview;
    passiveViewController *passiveview;
    NSUserDefaults *standarddef;
    NSString *checkoutlabel;
    int countchannel;
    
    NSManagedObjectContext *context;
    NSManagedObject *newunit;
    NSManagedObjectModel *fetchcontext;
    NSArray *alldata;
    NSMutableArray *itemsku;
    NSMutableArray *itemdescription;
    NSMutableArray *itemimage;
    NSMutableArray *itemprice;
    NSMutableArray *itemquantity;
    Product_info *productinfo;
    NSNumberFormatter *numberFormatter;
    
    NSMutableArray *cartitemsku;
    NSMutableArray *cartprice;
    NSMutableArray *cartquantity;
    NSMutableArray *cartdescription;
    
    UISwipeGestureRecognizer *swipeGesture;
    UIImageView *scanView;
    AVCaptureSession *capturesession;
    NSString *scanqrcode;
    UILabel *poptitle;
    NSString *scanprice;
    NSString *scanproduct;
    UIView *customView;
    UIView *popupbottomview;
    UILabel *productlabel;
    UIView *poptopview;
    UIView *popcontentview;
    writefiles *writefileclass;
    UITextField *remarkfield;
    UILabel *billremake;
    
    NSString *theqrcodemode;
}
@property (nonatomic, retain)NSString *calcualtvalue;
@property (nonatomic, retain) UIPageControl * pageControl;
@property (nonatomic, retain) IBOutlet UIButton *checkoutbutton;
@property (nonatomic, retain) IBOutlet UILabel *showvaluelabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonlabel;
@property (nonatomic, retain) IBOutlet UIButton *onpay;
@property (nonatomic, retain) IBOutlet UIButton *onpaypal;
@property (nonatomic, retain) IBOutlet UIButton *onwechat;
@property (nonatomic, retain) IBOutlet UIButton *onpayment;
@property (nonatomic, retain) IBOutlet UITextField *remarkfield;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *capturesession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end
