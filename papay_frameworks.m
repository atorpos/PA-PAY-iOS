//
//  papay_frameworks.m
//  PATerminal
//
//  Created by Oskar Wong on 2019/01/23.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import "papay_frameworks.h"

@implementation papay_frameworks

@synthesize loginid, passwd, mid, misc_info;
-(void)login {
    NSLog(@"the reading %@", loginid);
    papayinfo = [[papay_info alloc] init];
    [papayinfo performSelector:@selector(connectinfo:) withObject:@"grab info"];
}

-(void)query {
    
}

-(void)request {
    
}

@end
