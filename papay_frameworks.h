//
//  papay_frameworks.h
//  PATerminal
//
//  Created by Oskar Wong on 2019/01/23.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "papay_info.h"

NS_ASSUME_NONNULL_BEGIN

@interface papay_frameworks : NSObject {
    papay_info *papayinfo;
}
@property (nonatomic, nonnull) NSString *loginid;
@property (nonatomic, nonnull) NSString *passwd;
@property (nonatomic, nonnull) NSString *mid;
@property (nonatomic, nonnull) NSString *misc_info;

-(void)login;
@end

NS_ASSUME_NONNULL_END
