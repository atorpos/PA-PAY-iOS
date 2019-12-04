//
//  setimer.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/08/29.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ScreenViewController;
@interface setimer : NSObject
{
    NSTimer *autotimer;
    ScreenViewController *scc;
    NSString *pushresponse;
}
@property (nonatomic, strong) NSString *readthetext;
-(void)pusttoscreensaver;
-(void)settimer:(id)sender;
-(void)stoptime;
@end

NS_ASSUME_NONNULL_END
