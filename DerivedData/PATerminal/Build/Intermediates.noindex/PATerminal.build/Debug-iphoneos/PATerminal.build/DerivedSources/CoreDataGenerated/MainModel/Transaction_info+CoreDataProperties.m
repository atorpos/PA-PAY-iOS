//
//  Transaction_info+CoreDataProperties.m
//  
//
//  Created by Oskar Wong on 10/29/19.
//
//  This file was automatically generated and should not be edited.
//

#import "Transaction_info+CoreDataProperties.h"

@implementation Transaction_info (CoreDataProperties)

+ (NSFetchRequest<Transaction_info *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Transaction_info"];
}

@dynamic created_time;
@dynamic merchant_reference;
@dynamic order_amount;
@dynamic order_currency;
@dynamic provider_reference;
@dynamic request_reference;
@dynamic status;
@dynamic type;
@dynamic updated_time;

@end
