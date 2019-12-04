//
//  AllProductViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/17.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "AllProductViewController.h"
#import "AddProducts/AddProductViewController.h"
#import "EditProductViewController.h"
#import "writefiles.h"

@interface AllProductViewController ()

@end

@implementation AllProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"All Items", nil);
    
    [self runcd];
    //[request set]
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setDecimalSeparator:@"."];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:2];
    [numberFormatter setMaximumFractionDigits:2];
    
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    maintable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    maintable.delegate = self;
    maintable.dataSource = self;
    [self.view addSubview:maintable];
}
-(void)runcd {
    context = [self managedObjectContext];
    fetchcontext = [self managedObjectModel];
    itemsku = [[NSMutableArray alloc] init];
    itemdescription = [[NSMutableArray alloc] init];
    itemimage = [[NSMutableArray alloc] init];
    itemprice = [[NSMutableArray alloc] init];
    itemquantity = [[NSMutableArray alloc] init];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Product_info" inManagedObjectContext:context]];
    [request setIncludesSubentities:NO];
    
    alldata = [context executeFetchRequest:request error:nil];
    
    for (productinfo in alldata) {
        NSLog(@"%@, %@, %@", productinfo.sdk, productinfo.product_description, productinfo.product_id);
        [itemsku addObject:productinfo.sdk];
        [itemdescription addObject:productinfo.product_description];
        [itemprice addObject:productinfo.product_price];
        [itemquantity addObject:productinfo.product_quantity];
        if (productinfo.product_image == NULL) {
            UIImage *imageno = [UIImage imageNamed:@"no_image.png"];
            NSData *imagenodata = UIImagePNGRepresentation(imageno);
            [itemimage addObject:imagenodata];
        } else {
            [itemimage addObject:productinfo.product_image];
        }
        
    }
    //count item of coredata
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    NSLog(@"show count %lu", (unsigned long)count);
    
    NSEntityDescription *entity = [newunit entity];
    NSDictionary *attributes = [entity attributesByName];
    for (NSString *attribute in attributes) {
        id value = [newunit valueForKey:attribute];
        NSLog(@"attribute %@ = %@", attribute, value);
    }
}
-(void)viewDidAppear:(BOOL)animated {
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"allProduct.view"];
    [self runcd];
    [maintable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table view methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [alldata count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [maintable dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [itemdescription objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"SKU: %@", [itemsku objectAtIndex:indexPath.row]];
    [cell.imageView setImage:[UIImage imageWithData:[itemimage objectAtIndex:indexPath.row]]];
    
    UILabel *productprice = [[UILabel alloc] initWithFrame:CGRectMake(2*curwidth/3, 10, curwidth/3, 40)];
    productprice.text = [NSString stringWithFormat:@"HKD %@",  [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[[itemprice objectAtIndex:indexPath.row] doubleValue]]]];
    productprice.font = [UIFont systemFontOfSize:23];
    productprice.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:productprice];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, curwidth, 80)];
    headerview.backgroundColor = [UIColor whiteColor];
    
    UIButton *addproductbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    addproductbutton.frame = CGRectMake(20, 20, curwidth-40, 40);
    [addproductbutton setTitle:NSLocalizedString(@"Add Product", nil) forState:UIControlStateNormal];
    [addproductbutton setTitleColor:[UIColor colorWithRed:0.2 green:0.53 blue:0.98 alpha:1] forState:UIControlStateNormal];
    [addproductbutton setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] forState:UIControlStateHighlighted];
    [addproductbutton addTarget:self action:@selector(openaddproduct) forControlEvents:UIControlEventTouchUpInside];
    addproductbutton.layer.borderWidth = 0.5f;
    addproductbutton.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    addproductbutton.layer.cornerRadius = 10.0f;
    [headerview addSubview:addproductbutton];
    
    return headerview;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete");
    }
}

-(void)openaddproduct {
    addproductview = [self.storyboard instantiateViewControllerWithIdentifier:@"addproductview"];
    [self.navigationController presentViewController:addproductview animated:YES completion:nil];
}
-(void)saveContext {
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    editproductview = [storyboard instantiateViewControllerWithIdentifier:@"editproductview"];
    editproductview.productsku = [itemsku objectAtIndex:indexPath.row];
    editproductview.productdata = [itemimage objectAtIndex:indexPath.row];
    editproductview.productname = [itemdescription objectAtIndex:indexPath.row];
    editproductview.productprice = [itemprice objectAtIndex:indexPath.row];
    editproductview.productquantity = [itemquantity objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:editproductview animated:YES];
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
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    /*
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
