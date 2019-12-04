//
//  EditProductViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/15.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Product_info+CoreDataClass.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface EditProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureMetadataOutputObjectsDelegate> {
    CGFloat curwidth;
    CGFloat curheigh;
    UITableView *maintable;
    UITextField *inputnamefield;
    UITextField *skufield;
    UITextField *pricefield;
    UITextField *receivestock;
    NSUserDefaults *standarddefault;
    
}
@property (copy) NSString *productsku;
@property (copy) NSData *productdata;
@property (copy) NSString *productname;
@property (copy) NSString *productprice;
@property (copy) NSString *productquantity;

@end
