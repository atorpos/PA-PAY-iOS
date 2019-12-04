//
//  AppDelegate.m
//  PATerminal
//
//  Created by Oskar Wong on 2017/11/08.
//  Copyright © 2017 Oskar Wong. All rights reserved.
//
// ProximaNovaAlta-Light

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "writefiles.h"
#import "Reachability.h"
#import "TabBarViewController.h"
#import "Scan/ScanViewController.h"
#import "services.pch"

@interface AppDelegate ()

@end

@implementation AppDelegate
NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    

    //[Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    tabbarview = [[TabBarViewController alloc] init];
    
    NSLog(@"show objective %@", language = [[NSLocale preferredLanguages] firstObject]);
    NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
    if (url) {
        NSLog(@"url %@", [url query]);
    } else {
        NSLog(@"no url");
    }
    writeclass = [[writefiles alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    standardUser = [NSUserDefaults standardUserDefaults];
    NSString *version =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![standardUser objectForKey:@"appversion"] || ![[standardUser objectForKey:@"appversion"] isEqualToString:version]) {
        NSLog(@"remove all login session");
        [standardUser removeObjectForKey:@"MerchID"];
        [standardUser removeObjectForKey:@"loginid"];
        [standardUser removeObjectForKey:@"requsttime"];
        [standardUser removeObjectForKey:@"responsetime"];
        [standardUser removeObjectForKey:@"signtoken"];
        [standardUser removeObjectForKey:@"signature_secret"];
    }
        
    [standardUser setObject:@"HKD" forKey:@"usercurrency"];
    [standardUser setObject:[language substringToIndex:2] forKey:@"systemlanguage"];
    [standardUser setObject:@"0f0f0" forKey:@"MerchID"];
    [standardUser setObject:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] forKey:@"appstarttime"];
    //show bio
    NSString *appversion =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [standardUser setObject:appversion forKey:@"appversion"];
    [NSTimer scheduledTimerWithTimeInterval:120.0f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:1800.0f target:self selector:@selector(handlePost:) userInfo:nil repeats:YES];
    context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"";
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil] && [[standardUser objectForKey:@"bioauth"] isEqualToString:@"1"]) {
        if (@available(iOS 11.0, *)) {
            if (context.biometryType == LABiometryTypeFaceID) {
                NSLog(@"face id");
               
            } else if (context.biometryType == LABiometryTypeTouchID) {
                NSLog(@"touch id");
                
            }
        } else {
            NSLog(@"not ios 11");
            
            // Fallback on earlier versions
        }
    } else {
        NSLog(@"no bio");
        
    }
    if (remoteHostStatus == NotReachable) {
        NSLog(@"no internet");
        [self createnointernetview];
    } else {
        if([standardUser objectForKey:@"MerchID"] == nil) {
            NSLog(@"no token");
            [self.window.rootViewController performSegueWithIdentifier:@"loginsegue" sender:self.window.rootViewController];
        } else {
            NSLog(@"have token");
            
            [self createbackgroundview];
            
            NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standardUser objectForKey:@"signtoken"]];
            NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *qrcodequery = [NSString stringWithFormat:@"%@%@", PRODUCTIONURL, TRANSACTION_ENDPOINT];
            [request setURL:[NSURL URLWithString:qrcodequery]];
            [request setHTTPMethod:@"POST"];
            [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postdata];
            [request setTimeoutInterval:10.0];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (response &&! error) {
                    NSString *readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"QR %@", readtext);
                    if (![readtext isEqualToString:@"no value"]) {
                        [self performSelectorOnMainThread:@selector(fetchqr:) withObject:data waitUntilDone:YES];
                    } else {
                        NSLog(@"no value");
                    }
                } else {
                }
            }];
            
            [task resume];
            
        }
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDistanceFilter:10.0f];
    [locationManager startUpdatingLocation];
    if([CLLocationManager locationServicesEnabled]) {
        NSLog(@"the location is enabled");
    }else {
        NSLog(@"the location is disable");
    }
    NSString *fcmToken = [FIRMessaging messaging].FCMToken;
    [standardUser setObject:fcmToken forKey:@"fcmtoken"];
    NSLog(@"FCM registration token: %@", fcmToken);
    [writeclass writefile:@"app.open"];
    
    if([self.window.rootViewController.presentedViewController isViewLoaded]) {
        NSLog(@"the view is loaded");
    } else {
        NSLog(@"view is not loaded");
    }
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch begin");
}
-(void)handleNetworkChange:(NSNotification *)notice {
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable){
        NSLog(@"No connction");
        [self createnointernetview];
    }else {
        [self backfromsleep];
    }
}
-(void)handleTimer:(NSTimer *)timer {
    writeclass.updatelocation = [standardUser objectForKey:@"updatelocation"];
    NSLog(@"handle timer %@", [standardUser objectForKey:@"pagelocation"]);
    [writeclass writefile:[standardUser objectForKey:@"pagelocation"]];
}
-(void)handlePost:(NSTimer *)timer {
   [writeclass postfile:[standardUser objectForKey:@"signtoken"]];
}
-(void)fetchqr:(NSData *)requestdata {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    //NSLog(@"QRCode JSON %@", [[json objectForKey:@"payload"] objectForKey:@"qrcode"]);
    if([[[json objectForKey:@"response"] objectForKey:@"code"] intValue] == 500) {
        [self.window.rootViewController performSegueWithIdentifier:@"loginsegue" sender:self.window.rootViewController];
    } else {
        [self checkthebio];
    }
}
-(void)checkthebio {
    if ((![standardUser objectForKey:@"bioauth"] )|| ([[standardUser objectForKey:@"bioauth"] integerValue] == 0)) {
        [self.window.rootViewController performSegueWithIdentifier:@"LogedView" sender:self.window.rootViewController];
    } else {
        [self createbackgroundview];
        [self localAuthchan];
    }
    
}
-(void)localAuthchan {
    NSLog(@"value is on");
    NSError *authError = nil;
    NSString *Localreasonstring = @"Bio ID test is on";
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:Localreasonstring reply:^(BOOL success, NSError *error) {
            if(success) {
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->backgroundview removeFromSuperview];
                    [self.window.rootViewController performSegueWithIdentifier:@"LogedView" sender:self.window.rootViewController];
                });
            } else {
                NSLog(@"fail");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->backgroundview removeFromSuperview];
                    [self.window.rootViewController performSegueWithIdentifier:@"loginsegue" sender:self.window.rootViewController];
                });
            }
        }];
    } else {
        NSLog(@"no thing");
    }
}
-(void)backfromsleep {
    logcontext = [[LAContext alloc] init];
    logcontext.localizedFallbackTitle = @"Use Login";
    NSLog(@"value is on");
    NSError *authError = nil;
    NSString *Localreasonstring = @"Bio ID test is on";
    if ([logcontext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [logcontext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:Localreasonstring reply:^(BOOL success, NSError *error) {
            if(success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->backgroundview removeFromSuperview];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->backgroundview removeFromSuperview];
                    
                    //[self.window.rootViewController performSegueWithIdentifier:@"loginsegue" sender:self.window.rootViewController];
                });
            }}];
    } else {
        NSLog(@"other not success");
    }
}
-(void)createbackgroundview {
    backgroundview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    backgroundview.backgroundColor = [UIColor whiteColor];
    UIImageView *logoview = [[UIImageView alloc] init];
    logoview.frame = CGRectMake(10, self.window.frame.size.height/2-40, self.window.frame.size.width-20, 80);
    [logoview setImage:[UIImage imageNamed:@"pa_logo_1200x180.png"]];
    logoview.contentMode = UIViewContentModeScaleAspectFit;
    [backgroundview addSubview:logoview];
    [self.window addSubview:backgroundview];
}
-(void)createnointernetview {
    backgroundview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    backgroundview.backgroundColor = [UIColor whiteColor];
    UIImageView *logoview = [[UIImageView alloc] init];
    logoview.frame = CGRectMake(10, self.window.frame.size.height/2-100, self.window.frame.size.width-20, 80);
    [logoview setImage:[UIImage imageNamed:@"pa_logo_1200x180.png"]];
    logoview.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *nointernetlabel = [[UILabel alloc] init];
    nointernetlabel.frame = CGRectMake(10, self.window.frame.size.height/2, self.window.frame.size.width-20, 40);
    nointernetlabel.textAlignment = NSTextAlignmentCenter;
    nointernetlabel.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:32];
    nointernetlabel.text = @"No Internet Connection";
    [backgroundview addSubview:nointernetlabel];
    [backgroundview addSubview:logoview];
    [self.window addSubview:backgroundview];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *c = [locations objectAtIndex:0];
    MKCoordinateRegion region;
    CLLocationCoordinate2D setCoord;
    setCoord.latitude = c.coordinate.latitude;
    setCoord.longitude = c.coordinate.longitude;
    region.center = setCoord;
    //NSLog(@"here is the location %f, %f", region.center.latitude, region.center.longitude);
    
    [standardUser setObject:[NSString stringWithFormat:@"%f+%f", region.center.latitude, region.center.longitude] forKey:@"launchlocation"];
    [standardUser setObject:[NSString stringWithFormat:@"%f+%f", region.center.latitude, region.center.longitude] forKey:@"updatelocation"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [locationManager stopUpdatingLocation];
    NSLog(@"into background");
    [tabbarview tabbarinidle];
    [self createbackgroundview];
    [standardUser setObject:[standardUser objectForKey:@"launchlocation"] forKey:@"lastlocation"];
    [standardUser setObject:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] forKey:@"enterbackgroundtime"];
    int activetime = [[standardUser objectForKey:@"enterbackgroundtime"] intValue] - [[standardUser objectForKey:@"appstarttime"] intValue];
    NSLog(@"check time %d", activetime);
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    application.applicationIconBadgeNumber = -1;
    [writeclass writefile:@"app.backgorund"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    //[self->backgroundview removeFromSuperview];
    //[self.window.rootViewController performSegueWithIdentifier:@"scantheview" sender:self.window.rootViewController];
    
    
    NSLog(@"back to foreground %@", [standardUser objectForKey:@"lastlocation"]);
    [standardUser setObject:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] forKey:@"enterforeground"];
    int idletime = [[standardUser objectForKey:@"enterforeground"] intValue] - [[standardUser objectForKey:@"enterbackgroundtime"] intValue];
    NSLog(@"check time %d", idletime);
    [tabbarview tabbarrestart];
    [self->backgroundview removeFromSuperview];
    [writeclass writefile:@"app.foreground"];
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //scanview = [storyboard instantiateViewControllerWithIdentifier:@"intscanview"];
    //scanview.chargingvalue = receivedvalue;
    //self.window.rootViewController = scanview;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"app did become active");
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [locationManager stopUpdatingLocation];
    NSLog(@"close app");
    [standardUser setObject:[standardUser objectForKey:@"launchlocation"] forKey:@"lastlocation"];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [writeclass writefile:@"app.terminated"];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [standardUser setObject:token forKey:@"devicetoken"];
    NSLog(@"content---%@", token);
    [FIRMessaging messaging].APNSToken = deviceToken;
}
/**
-(void)testconnection {
    reachable = [Reachability reachabilityWithHostname:@"https://www.google.com"];
    reachable.reachableBlock = ^(Reachability*reach){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"have internet");
        });
    };
    reachable.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"don't have internet");
        });
    };
    [reachable startNotifier];
}
*/
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"recived the notification %@", userInfo);
    //UIView *getnot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //getnot.backgroundColor = [UIColor whiteColor];
    //[self.window addSubview:getnot];
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID %@", userInfo[kGCMMessageIDKey]);
    }
}
-(void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    [standardUser setObject:fcmToken forKey:@"FBCMtoken"];
}

//notifiacation process

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    NSLog(@"receive msg %@", userInfo);
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"the notifiacation: %@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    [notificationView removeFromSuperview];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayback  error:&err];
    AudioServicesPlayAlertSound(1012);
    
    notificationView = [[UIView alloc] init];
    notificationView.frame = CGRectMake(10, 20, self.window.frame.size.width-20, 100);
    notificationView.backgroundColor = [UIColor whiteColor];
    notificationView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    notificationView.layer.borderWidth = 1.0f;
    
    UIButton *dismissbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissbutton.frame = CGRectMake(notificationView.frame.size.width-120, notificationView.frame.size.height-25, 115, 20);
    [dismissbutton setTitle:NSLocalizedString(@"dismiss", nil) forState:UIControlStateNormal];
    dismissbutton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    [dismissbutton setTitleColor:[UIColor colorWithRed:0.33 green:0.60 blue:0.88 alpha:0.9] forState:UIControlStateNormal];
    [dismissbutton addTarget:self action:@selector(dismissnotview:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *alerttitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, notificationView.frame.size.width-10, 19)];
    alerttitle.text = NSLocalizedString(@"Transcation Alert", nil);
    alerttitle.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    alerttitle.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    UILabel *notifdetail = [[UILabel alloc] initWithFrame:CGRectMake(5, notificationView.frame.size.height/2-10, notificationView.frame.size.width-10, 20)];
    //wildcard of the notification.
    notifdetail.text = [NSString stringWithFormat:@"%@", [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]];
    notifdetail.font = [UIFont systemFontOfSize:17 weight:UIFontWeightThin];
    notifdetail.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    
    [notificationView addSubview:notifdetail];
    [notificationView addSubview:alerttitle];
    [notificationView addSubview:dismissbutton];
    [self.window addSubview:notificationView];
    completionHandler(UIBackgroundFetchResultNewData);
}
-(void)dismissnotview:(id)sender {
    [notificationView removeFromSuperview];
}

#pragma mark - Core Data stack

@synthesize managedObejctContext = _managedObejctContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MainModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MainModel.sqlite"];
    NSPersistentStore *store = [_persistentStoreCoordinator persistentStoreForURL:storeURL];
    
    NSError *error = nil;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *standarddefault = [NSUserDefaults standardUserDefaults];
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObejctContext != nil) {
        return _managedObejctContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    //change to initwithconcurrencytype after ios9
    _managedObejctContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObejctContext setPersistentStoreCoordinator:coordinator];
    return _managedObejctContext;
}

-(void) deleteAllObjects:(NSString *) entityDescription {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObejctContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObejctContext executeFetchRequest:fetchRequest error:&error];
    
    for(NSManagedObject *managedObject in items) {
        [_managedObejctContext deleteObject:managedObject];
    }
    if(![_managedObejctContext save:&error]) {
        NSLog(@"error deleting");
    }
    
}
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    //NSString *testingstring = [url query];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *urlarray = [urlComponents queryItems];
    [standardUser setObject:[[urlarray valueForKey:@"value"] objectAtIndex:0] forKey:@"onetimeprice"];
    NSLog(@"url array %@", [[urlarray valueForKey:@"value"] objectAtIndex:0]);
    receivedvalue = [NSString stringWithFormat:@"%@", [[urlarray valueForKey:@"value"] objectAtIndex:0]];
    //[self.window.rootViewController performSegueWithIdentifier:@"scantheview" sender:self.window.rootViewController];
    //[self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
