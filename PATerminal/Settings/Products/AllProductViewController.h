//
//  AllProductViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/17.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Product_info+CoreDataClass.h"

@class AddProductViewController;
@class EditProductViewController;
@class writefiles;
@interface AllProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *maintable;
    CGFloat curwidth;
    CGFloat curheigh;
    AddProductViewController *addproductview;
    EditProductViewController *editproductview;
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
    writefiles *writefileclass;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
-(void)saveContext;
@end
