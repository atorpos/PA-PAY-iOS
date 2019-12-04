//
//  AddProductViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/17.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "AddProductViewController.h"
#import "AddPhotoImgViewController.h"
#import "ScanBarcodeViewController.h"
#import "CNPPopupController.h"


@interface AddProductViewController () <CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation AddProductViewController
@synthesize capturesession, videoPreviewLayer, typeofclick;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"type %@", typeofclick);
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    
    context = [self managedObjectContext];
    fetchcontext = [self managedObjectModel];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UITapGestureRecognizer *taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didtapanywhere:)];
    standarddefault = [NSUserDefaults standardUserDefaults];
    [self.view addGestureRecognizer:taprecognizer];
    maintable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    maintable.delegate = self;
    maintable.dataSource = self;
    [maintable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:maintable];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.6 alpha:1]}];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeview:)];
    //[rightbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.6 alpha:1], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    //UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Check Out"];
    //item.leftBarButtonItem = rightbutton;
    //item.hidesBackButton = YES;
    self.navigationItem.title = NSLocalizedString(@"Create Item", nil);
    self.navigationItem.leftBarButtonItem = rightbutton;
    
    UIBarButtonItem *savbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveview:)];
    //[savbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithWhite:0.6 alpha:1], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = savbutton;
    
    
}
-(void)viewDidAppear:(BOOL)animated {
    [maintable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"text tag %ld", (long)textField.tag);
    NSInteger nextTag = textField.tag +1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    if(nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

-(IBAction)closeview:(id)sender {
    [standarddefault removeObjectForKey:@"add_sku"];
    [standarddefault removeObjectForKey:@"selected_image"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}
-(IBAction)saveview:(id)sender {
    inputname = inputnamefield.text;
    inputsku = skufield.text;
    inputprice = pricefield.text;
    inputstock = receivestock.text;
    productinfo = [NSEntityDescription insertNewObjectForEntityForName:@"Product_info" inManagedObjectContext:context];
    productinfo.sdk = inputsku;
    productinfo.product_description = inputname;
    productinfo.product_price = inputprice;
    productinfo.product_quantity = inputstock;
    productinfo.product_image = [standarddefault objectForKey:@"selected_image"];
    [context save:nil];
    NSLog(@"%@, %@, %@, %@", inputname, inputsku, inputprice, inputstock);
    [standarddefault removeObjectForKey:@"add_sku"];
    [standarddefault removeObjectForKey:@"selected_image"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)scancode:(id)sender {
    NSLog(@"scan");
     [self showscancode:CNPPopupStyleFullscreen];
}
#pragma mark Table view methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [maintable dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            inputnamefield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            inputnamefield.leftView = paddingview;
            inputnamefield.delegate = self;
            inputnamefield.tag = 0;
            inputnamefield.keyboardType = UIKeyboardTypeASCIICapable;
            inputnamefield.leftViewMode = UITextFieldViewModeAlways;
            inputnamefield.placeholder = @"Name";
            if(inputname) {
                inputnamefield.text = inputname;
            } else {
                NSLog(@"null field");
            }
            inputnamefield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            inputnamefield.layer.borderWidth = 0.5f;
            inputnamefield.tag = 1;
            [inputnamefield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:inputnamefield];
        }
            break;
        case 1:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            skufield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            skufield.leftView = paddingview;
            skufield.delegate = self;
            skufield.tag = 1;
            skufield.keyboardType = UIKeyboardTypeASCIICapable;
            skufield.textColor = [UIColor blackColor];
            skufield.leftViewMode = UITextFieldViewModeAlways;
            skufield.placeholder = @"SKU";
            skufield.adjustsFontSizeToFitWidth = YES;
            skufield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            skufield.layer.borderWidth = 0.5f;
            skufield.tag = 2;
            if (scanqrcode) {
                skufield.text = scanqrcode;
            }
            UIButton *scanbarcode = [UIButton buttonWithType:UIButtonTypeCustom];
            scanbarcode.frame = CGRectMake(skufield.frame.size.width-40, 5, 30, 30);
            [scanbarcode setTitle:@"" forState:UIControlStateNormal];
            [scanbarcode addTarget:self action:@selector(scancode:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *scancodeview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanbarcode.frame.size.width, scanbarcode.frame.size.height)];
            scancodeview.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *scancodeimg = [UIImage imageNamed:@"Camera-icon.png"];
            [scancodeview setImage:scancodeimg];
            [scanbarcode addSubview:scancodeview];
            [skufield addSubview:scanbarcode];
            [skufield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:skufield];
        }
            break;
        case 2:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            pricefield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            pricefield.leftView = paddingview;
            pricefield.delegate = self;
            pricefield.tag = 3;
            pricefield.keyboardType = UIKeyboardTypeDecimalPad;
            pricefield.leftViewMode = UITextFieldViewModeAlways;
            pricefield.placeholder = @"Price";
            pricefield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            pricefield.layer.borderWidth = 0.5f;
            pricefield.tag = 3;
            if(inputprice) {
                pricefield.text = inputprice;
            }
            [pricefield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:pricefield];
        }
            break;
        case 3:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            receivestock = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            receivestock.leftView = paddingview;
            receivestock.delegate = self;
            receivestock.tag = 4;
            receivestock.keyboardType = UIKeyboardTypeNumberPad;
            receivestock.leftViewMode = UITextFieldViewModeAlways;
            receivestock.placeholder = @"Received Stock";
            receivestock.layer.borderColor = [UIColor lightGrayColor].CGColor;
            receivestock.layer.borderWidth = 0.5f;
            receivestock.tag = 4;
            if(inputstock) {
                receivestock.text = inputstock;
            }
            [receivestock addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:receivestock];
        }
            break;
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 120)];
    headerview.backgroundColor = [UIColor whiteColor];
    
    UIButton *addproductbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    addproductbutton.frame = CGRectMake(curwidth/2-70, 10, 140, 140);
    
    [addproductbutton setTitleColor:[UIColor colorWithRed:0.2 green:0.53 blue:0.98 alpha:1] forState:UIControlStateNormal];
    [addproductbutton setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] forState:UIControlStateHighlighted];
    [addproductbutton addTarget:self action:@selector(bmethod:) forControlEvents:UIControlEventTouchUpInside];
    //[addproductbutton addTarget:self action:@selector(openaddproduct) forControlEvents:UIControlEventTouchUpInside];
    addproductbutton.layer.borderWidth = 0.5f;
    addproductbutton.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    //addproductbutton.layer.cornerRadius = 10.0f;
    if ([standarddefault objectForKey:@"selected_image"]) {
        UIImageView *buttonimageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, addproductbutton.frame.size.width, addproductbutton.frame.size.height)];
        UIImage *buttonimage = [UIImage imageWithData:[standarddefault objectForKey:@"selected_image"]];
        [buttonimageview setImage:buttonimage];
        [addproductbutton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
        [addproductbutton addSubview:buttonimageview];
    } else {
        [addproductbutton setTitle:NSLocalizedString(@"Add Photo", nil) forState:UIControlStateNormal];
    }
    [headerview addSubview:addproductbutton];
    
    return headerview;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"sohw textfield %ld", (long)textField.tag);
    switch (textField.tag) {
        case 1:
        {
            inputname = inputnamefield.text;
        }
            break;
        case 2:
        {
            inputsku = skufield.text;
        }
            break;
        case 3:
        {
            inputprice = pricefield.text;
        }
            break;
        case 4:
        {
            inputstock = receivestock.text;
        }
        default:
            break;
    }
    
}

-(void)didtapanywhere:(UITapGestureRecognizer *)recognizer {
    NSLog(@"tap things");
    [inputnamefield resignFirstResponder];
    [skufield resignFirstResponder];
    [pricefield resignFirstResponder];
    [receivestock resignFirstResponder];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"text start");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"text ended");
    [textField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    return YES;
}

-(void)keyboardDidShow:(NSNotification *)notification {
    [maintable setFrame:CGRectMake(0, -115, curwidth, curheigh-115)];
}
-(void)keyboardDidHide:(NSNotification *)notification {
    [maintable setFrame:CGRectMake(0, 0, curwidth, curheigh)];
}
-(IBAction)bmethod:(id)sender {
    NSLog(@"select b method");
    [self showPopupWithStyle:CNPPopupStyleFullscreen];
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //addphotoview = [storyboard instantiateViewControllerWithIdentifier:@"addphotoview"];
    //[self.navigationController pushViewController:addphotoview animated:YES];
    //[navcon presentViewController:addphotoview animated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:addphotoview];
}
-(IBAction)searchcd:(id)sender {
    NSLog(@"test %@", sender);
    NSArray *fetchObjects;
    context = [self managedObjectContext];
    fetchcontext = [self managedObjectModel];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entitDescription = [NSEntityDescription entityForName:@"Product_info" inManagedObjectContext:context];
    [fetch setEntity:entitDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ANY sdk contains[cd] %@)", sender]];
    NSError *error = nil;
    fetchObjects = [context executeFetchRequest:fetch error:&error];
    NSLog(@"show array %@", [fetchObjects objectAtIndex:0]);

}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.altawoz.testtable" in the application's documents directory.
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
    /*
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *standarddefault = [NSUserDefaults standardUserDefaults];
    if (version != [standarddefault objectForKey:@"bundlestring"]) {
        [standarddefault setObject:version forKey:@"bundlestring"];
        [standarddefault setObject:@"0" forKey:@"lastDinputvalue"];
        [standarddefault removeObjectForKey:@"firstdatadump"];
        [standarddefault removeObjectForKey:@"lastinputvalue"];
        [_persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
    } else {
        NSLog(@"bundle %@", [standarddefault objectForKey:@"bundlestring"]);
        
    }
    */
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        
        NSLog(@"things success");
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
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

- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle {
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Product Photo" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    topview.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"x" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6];
    button.layer.cornerRadius = 0;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, curwidth, 60);
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UIView *buttonview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 80)];
    
    UIButton *takephoto = [UIButton buttonWithType:UIButtonTypeCustom];
    takephoto.frame = CGRectMake(0, 0, curwidth/2, 80);
    [takephoto setTitle:@"Take Photo" forState:UIControlStateNormal];
    [takephoto addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    takephoto.backgroundColor = [UIColor lightGrayColor];
    [buttonview addSubview:takephoto];
    
    UIButton *choosephoto = [UIButton buttonWithType:UIButtonTypeCustom];
    choosephoto.frame = CGRectMake(curwidth/2, 0, curwidth/2, 80);
    [choosephoto setTitle:@"Choose Photo" forState:UIControlStateNormal];
    [choosephoto addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    choosephoto.backgroundColor = [UIColor grayColor];
    [buttonview addSubview:choosephoto];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curwidth)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height);
    if ([standarddefault objectForKey:@"selected_image"]) {
        UIImage *buttonimage = [UIImage imageWithData:[standarddefault objectForKey:@"selected_image"]];
        [imageView setImage:buttonimage];
    }else {
        UIImage *buttonimage = [UIImage imageNamed:@"no-image.png"];
        [imageView setImage:buttonimage];
    }
    
    [customView addSubview:imageView];
    [topview addSubview:button];
    [topview addSubview:titleLabel];
    
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[topview, customView, buttonview]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}
-(void)showscancode:(CNPPopupStyle)popupStyle {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Scan Code" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 60)];
    topview.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    //topview.backgroundColor = [UIColor clearColor];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"x" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6];
    button.layer.cornerRadius = 0;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0, curwidth, 60);
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh-120)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    scanView = [[UIImageView alloc] init];
    scanView.frame = CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height);
    [self qrcamfnt];
    [customView addSubview:scanView];
    [topview addSubview:button];
    [topview addSubview:titleLabel];
    
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[topview, customView]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
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
    imageView.image = chosenImage;
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.8);
    [standarddefault setObject:imageData forKey:@"selected_image"];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.popupController dismissPopupControllerAnimated:YES];
    
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
                videoPreviewLayer.frame = scanView.bounds;
                [scanView.layer addSublayer:videoPreviewLayer];
                [capturesession startRunning];
            }
        }
    }
    //end of QR cam
}
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSLog(@"the code %@", [metadataObj stringValue]);
        scanqrcode = [metadataObj stringValue];
        [capturesession stopRunning];
        //[scanView removeFromSuperview];
        [self stopReading];
        //capturesession = nil;
        //[standarddefault setObject:scanqrcode forKey:@"add_sku"];
        //[self.popupController dismissPopupControllerAnimated:YES];
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
-(BOOL)startReading {
    
    return YES;
}
-(void)stopReading {
    capturesession = nil;
    [standarddefault setObject:scanqrcode forKey:@"add_sku"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.popupController dismissPopupControllerAnimated:YES];
        [self->maintable reloadData];
    });
    
    //[self.popupController dismissPopupControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
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
