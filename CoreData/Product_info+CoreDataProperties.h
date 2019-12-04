//
//  Product_info+CoreDataProperties.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/16.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//
//

#import "Product_info+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Product_info (CoreDataProperties)

+ (NSFetchRequest<Product_info *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sdk;
@property (nullable, nonatomic, copy) NSString *product_id;
@property (nullable, nonatomic, copy) NSString *product_description;
@property (nullable, nonatomic, copy) NSString *product_price;
@property (nullable, nonatomic, copy) NSString *product_quantity;
@property (nullable, nonatomic, copy) NSString *product_sold;
@property (nullable, nonatomic, copy) NSDate *product_image;

@end

NS_ASSUME_NONNULL_END
