//
//  Product_info+CoreDataProperties.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/16.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//
//

#import "Product_info+CoreDataProperties.h"

@implementation Product_info (CoreDataProperties)

+ (NSFetchRequest<Product_info *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Product_info"];
}

@dynamic sdk;
@dynamic product_id;
@dynamic product_description;
@dynamic product_price;
@dynamic product_quantity;
@dynamic product_sold;
@dynamic product_image;

@end
