//
//  setimer.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/08/29.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "setimer.h"
#import "ScreenViewcontroller.h"

@implementation setimer
@synthesize readthetext;

-(void)pusttoscreensaver {
    //[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(targetMethod:) userInfo:nil repeats:NO];
    
}

-(void)targetMethod:(id)sender
{
    readthetext = @"change the text from timer";
    NSLog(@"read text %@", readthetext);
}

-(void)settimer:(id)sender
{
    float timetode = [sender floatValue];
    autotimer = [NSTimer scheduledTimerWithTimeInterval:timetode target:self selector:@selector(showscreen) userInfo:nil repeats:NO];
    //autotimer = [NSTimer timerWithTimeInterval:timetode target:self selector:@selector(showscreen) userInfo:nil repeats:YES];
}

-(void)stoptime {
    NSLog(@"reset time");
    [autotimer invalidate];
    autotimer = nil;
    [self settimer:@"5.0"];
}
-(void)showscreen
{
    NSLog(@"testing timer");
    
}
@end
