//
//  AppDelegate.h
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "Reachability.h"
#import "Firebase.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import <StarIO_Extension/StarIoExt.h>
#import <LocalAuthentication/LocalAuthentication.h>

@import FirebaseCore;
@import FirebaseMessaging;
@import FirebaseInstanceID;
@class writefiles;
@class Reachability;
@class TabBarViewController;
@class ScanViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate> {
    CLLocationManager *locationManager;
    NSUserDefaults *standardUser;
    NSString *foundaddress;
    Reachability *reachable;
    UIView *notificationView;
    UIView *backgroundview;
    UIImageView *logoview;
    LAContext *context;
    LAContext *logcontext;
    writefiles *writeclass;
    Reachability *reachability;
    TabBarViewController *tabbarview;
    ScanViewController *scanview;
    NSTimer *autotimer;
    NSString *receivedvalue;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObejctContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;


@end

