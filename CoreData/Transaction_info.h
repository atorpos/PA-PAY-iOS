//
//  Transaction_info.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/15.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Transaction_info : NSManagedObject

@property (nonatomic, retain) NSString * created_time;
@property (nonatomic, retain) NSString * merchant_reference;
@property (nonatomic, retain) NSString * order_amount;
@property (nonatomic, retain) NSString * order_currency;
@property (nonatomic, retain) NSString * provider_reference;
@property (nonatomic, retain) NSString * request_reference;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * updated_time;

@end
