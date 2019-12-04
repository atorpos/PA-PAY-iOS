//
//  Transaction_info+CoreDataProperties.h
//  
//
//  Created by Oskar Wong on 10/29/19.
//
//  This file was automatically generated and should not be edited.
//

#import "Transaction_info.h"


NS_ASSUME_NONNULL_BEGIN

@interface Transaction_info (CoreDataProperties)

+ (NSFetchRequest<Transaction_info *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *created_time;
@property (nullable, nonatomic, copy) NSString *merchant_reference;
@property (nullable, nonatomic, copy) NSString *order_amount;
@property (nullable, nonatomic, copy) NSString *order_currency;
@property (nullable, nonatomic, copy) NSString *provider_reference;
@property (nullable, nonatomic, copy) NSString *request_reference;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *updated_time;

@end

NS_ASSUME_NONNULL_END
