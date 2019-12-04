//
//  writefiles.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/08/28.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface writefiles : NSObject
{
    NSUserDefaults *standardDef;
}

@property (copy) NSString *updatelocation;
@property (copy) NSString *copyplace;
-(void)writefile:(id)sender;
-(void)setpageview:(id)sender;
-(void)postfile:(id)sender;
@end

NS_ASSUME_NONNULL_END
