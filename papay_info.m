//
//  papay_info.m
//  PATerminal
//
//  Created by Oskar Wong on 2019/01/25.
//  Copyright © 2019 Oskar Wong. All rights reserved.
//

#import "papay_info.h"

@implementation papay_info
@synthesize returndata;

-(IBAction)connectinfo:(id)sender {
    standardUser = [NSUserDefaults standardUserDefaults];
    transitionquery = @"https://gateway.pa-sys.com/alipay/information";
    
    posttoken = [NSString stringWithFormat:@"token=%@", [standardUser objectForKey:@"signtoken"]];
    NSLog(@"Can't %@ %@", sender, posttoken);
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:transitionquery]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"QR %@", self->readtext);
            if (![self->readtext isEqualToString:@"no value"]) {
                //[self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
                self->returndata = data;
            } else {
                self->returndata = [@"novalue" dataUsingEncoding:NSUTF16StringEncoding];
            }
        } else {
        }
        
    }];
    
    [task resume];
}

@end
