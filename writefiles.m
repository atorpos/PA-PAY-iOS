//
//  writefiles.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/08/28.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "writefiles.h"
#import "AESCrypt.h"

@implementation writefiles
@synthesize updatelocation, copyplace;

-(instancetype)init {
    self = [super init];
    
    return self;
}
-(void)setpageview:(id)sender {
    standardDef = [NSUserDefaults standardUserDefaults];
    [standardDef setObject:sender forKey:@"pagelocation"];
}

-(void)writefile:(id)sender {
    NSLog(@"it is a class file %@", sender);
    standardDef = [NSUserDefaults standardUserDefaults];
    
    NSArray *listposition = [updatelocation componentsSeparatedByString:@"+"];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"activity.txt"];
    
    if (![filemanager fileExistsAtPath:filePath]) {
        NSString *stringToWrite = [NSString stringWithFormat:@"{\"action_time\": %f,\n\"page\":\"app.create\"}",[[NSDate date] timeIntervalSince1970]];
        NSLog(@"no file");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            [stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        });
    } else {
        NSString *stringToWrite = [NSString stringWithFormat:@",\n{\"action_time\":\"%f\",\n\"page\":\"%@\",\n\"app_version\":\"%@\",\"longitude\":\"%@\",\n\"latitude\":\"%@\"}",[[NSDate date] timeIntervalSince1970], sender, [standardDef objectForKey:@"appversion"],[listposition objectAtIndex:1], [listposition objectAtIndex:0]];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[stringToWrite dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
}
-(void)postfile:(id)sender {
    NSLog(@"sender value = %@", sender);
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"activity.txt"];
    if ([filemanager fileExistsAtPath:filePath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            NSString *filecontents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
            NSString *heartbeaturl = @"https://gateway.pa-sys.com/alipay/heartbeat";
            NSString *heartbeatcontent = [NSString stringWithFormat:@"{\"heartbeat\":[%@]}", filecontents];
            //test AES
            
            
            //NSData *plain = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSString *key = @"U5eHeARyg3cf33AwcH7AZ65XUuFAxhfw";
            
            NSString *encryData = [AESCrypt encrypt:heartbeatcontent password:key];
            NSLog(@"the ecypt code %@", encryData);
            //post without a encryption
            NSString *posttoken = [NSString stringWithFormat:@"token=%@&data=%@", sender, heartbeatcontent];
            NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:heartbeaturl]];
            [request setHTTPMethod:@"POST"];
            [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postdata];
            [request setTimeoutInterval:10.0];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (response &&! error) {
                    NSString *readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (![readtext isEqualToString:@"no value"]) {
                        [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
                    } else {
                        NSLog(@"no value");
                    }
                } else {
                }
            }];
            
            [task resume];
        });
        
    }
}
-(void)fetchdata:(NSData *)requestdata {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    if([[[json valueForKey:@"response"] valueForKey:@"code"] integerValue] == 200) {
        NSString *stringToWrite = [NSString stringWithFormat:@"{\"action_time\": %f,\n\"page\":\"heartbeat.post\"}",[[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"activity.txt"];
        [stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

@end
