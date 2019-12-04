//
//  papay_info.h
//  PATerminal
//
//  Created by Oskar Wong on 2019/01/25.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface papay_info : NSObject {
    NSString *transitionquery;
    NSString *posttoken;
    NSUserDefaults *standardUser;
    NSString *readtext;
}
@property (nonatomic, nonnull) NSString *returnvalue;
@property (nonatomic, nonnull) NSData *returndata;
-(IBAction)connectinfo:(id)sender;
@end

NS_ASSUME_NONNULL_END
