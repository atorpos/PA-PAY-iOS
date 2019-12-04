//
//  EditAccountViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/19.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "EditAccountViewController.h"
#import "LoginViewController.h"
#import "writefiles.h"
#import "services.pch"
@interface EditAccountViewController ()

@end

@implementation EditAccountViewController
@synthesize newpassword, oldpassword, conpassword, donebutton, taprecognizer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Change Password", nil);
    storepasswd = NO;
    newpasswd = NO;
    repasswd = NO;
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    taprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundclick:)];
    taprecognizer.cancelsTouchesInView = NO;
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    tableview.delegate = self;
    tableview.dataSource = self;
    standarddef = [NSUserDefaults standardUserDefaults];
    donebutton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)  style:UIBarButtonItemStyleDone target:self action:@selector(changepasswd:)];
    self.navigationItem.rightBarButtonItem = donebutton;
    [donebutton setEnabled:NO];
    [self.view addGestureRecognizer:taprecognizer];
    [self.view addSubview:tableview];
}
-(void)viewDidAppear:(BOOL)animated
{
    writefileclass = [[writefiles alloc] init];
    [writefileclass setpageview:@"settings.view"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)changepasswd:(id)sender {
    NSLog(@"change passwd");
    NSString *sentchange = [NSString stringWithFormat:@"token=%@&password=%@&new_password=%@&re_password=%@",[standarddef objectForKey:@"signtoken"], oldpassword.text, newpassword.text, conpassword.text];
    NSString *changepassurlstr = [NSString stringWithFormat:@"%@%@", PRODUCTIONURL, CHANGEPW_ENDPOINT];
    NSLog(@"the string %@, %@", changepassurlstr, sentchange);
    NSData *postdata = [sentchange dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[sentchange length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:changepassurlstr]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            self->readtext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self performSelectorOnMainThread:@selector(fetchresponse:) withObject:data waitUntilDone:YES];
        }
    }];
    [task resume];
    
    
}
-(void)fetchresponse:(NSData *)responseData {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSLog(@"show json %@", json);
    if([[[json valueForKey:@"response"] valueForKey:@"code"] intValue]== 200) {
        signmessage = [[[json valueForKey:@"payload"] valueForKey:@"message"] uppercaseString];
         [self performSelectorOnMainThread:@selector(succmsg:) withObject:signmessage waitUntilDone:NO];
        [standarddef setObject:newpassword.text forKey:@"userpassword"];
        [self performSelector:@selector(succmsg:) withObject:signmessage afterDelay:0];
        
        [self.navigationController popViewControllerAnimated:YES];
        //[self performSelectorOnMainThread:@selector(succmsg:) withObject:signmessage waitUntilDone:YES];
        
        
    } else {
        signmessage = [[json valueForKey:@"response"] valueForKey:@"message"];
        [self performSelectorOnMainThread:@selector(errormsg:) withObject:signmessage waitUntilDone:YES];
    }
}
-(void)errormsg :(NSString *)response{
    
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:response preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:ok];
    [self presentViewController:alertcontroller animated:YES completion:nil];
}
-(void)succmsg :(NSString *)response{
    NSLog(@"response %@", response);
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil) message:response preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    
    [alertcontroller addAction:ok];
    [self presentViewController:alertcontroller animated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)cancelallsession:(id)sender {
    NSLog(@"logout");
    NSUserDefaults *standarduser = [NSUserDefaults standardUserDefaults];
    [standarduser removeObjectForKey:@"MerchID"];
    [standarduser removeObjectForKey:@"loginid"];
    [standarduser removeObjectForKey:@"requsttime"];
    [standarduser removeObjectForKey:@"responsetime"];
    [standarduser removeObjectForKey:@"signtoken"];
    [standarduser removeObjectForKey:@"signature_secret"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    loginview = [storyboard instantiateViewControllerWithIdentifier:@"loginview"];
    
    [self presentViewController:loginview animated:YES completion:nil];
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == oldpassword) {
        NSLog(@"old password %@", oldpassword.text);
        if([oldpassword.text isEqualToString:[standarddef objectForKey:@"userpassword"]]) {
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"correct.png"]];
            [oldpassword addSubview:outputresult];
            storepasswd = YES;
        } else {
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"incorrect.png"]];
            [oldpassword addSubview:outputresult];
            storepasswd = NO;
        }
    } else if(textField == newpassword) {
        NSLog(@"new password %@", newpassword.text);
        if([newpassword.text length] > 7) {
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"correct.png"]];
            [newpassword addSubview:outputresult];
            newpasswd = YES;
        } else {
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"incorrect.png"]];
            [newpassword addSubview:outputresult];
            newpasswd = NO;
        }
    } else if (textField == conpassword) {
        NSLog(@"%@ - %@", conpassword.text, newpassword.text);
        if([conpassword.text length] == 0 || ![conpassword.text isEqualToString:newpassword.text]) {
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"incorrect.png"]];
            [conpassword addSubview:outputresult];
            repasswd = NO;
        } else {
            NSLog(@"correct");
            UIImageView *outputresult = [[UIImageView alloc] initWithFrame:CGRectMake(oldpassword.frame.size.width-20, 7, 15, 15)];
            [outputresult setImage:[UIImage imageNamed:@"correct.png"]];
            [conpassword addSubview:outputresult];
            repasswd = YES;
        }
    }
    if (storepasswd == YES && newpasswd == YES && repasswd == YES) {
        [donebutton setEnabled:YES];
    } else {
        [donebutton setEnabled:NO];
    }
}
-(IBAction)backgroundclick:(id)sender {
    
    [[self view] endEditing:YES];
}

#pragma mark Table view methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowinsection;
    switch (section) {
        case 0:
            rowinsection = 3;
            break;
        case 1:
            rowinsection = 3;
            break;
        default:
            rowinsection = 0;
            break;
    }
    return rowinsection;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [tableview dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    switch (indexPath.section) {
        case 0:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        oldpassword = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, curwidth-20, 30)];
                        oldpassword.delegate = self;
                        oldpassword.placeholder = NSLocalizedString(@"Old Password", nil);
                        oldpassword.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
                        oldpassword.textAlignment = NSTextAlignmentLeft;
                        oldpassword.userInteractionEnabled = YES;
                        oldpassword.secureTextEntry = YES;
                        oldpassword.layer.masksToBounds = true;
                        [cell.contentView addSubview:oldpassword];
                    }
                        break;
                    case 1:
                    {
                        newpassword = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, curwidth-20, 30)];
                        newpassword.delegate = self;
                        newpassword.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
                        newpassword.textAlignment = NSTextAlignmentLeft;
                        newpassword.userInteractionEnabled = YES;
                        newpassword.secureTextEntry = YES;
                        newpassword.layer.masksToBounds = true;
                        newpassword.placeholder = NSLocalizedString(@"New Password", nil);
                        
                        [cell.contentView addSubview:newpassword];
                    }
                        break;
                    case 2:
                    {
                        conpassword = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, curwidth-20, 30)];
                        conpassword.delegate = self;
                        conpassword.font = [UIFont fontWithName:@"ProximaNovaAlta-Light" size:17];
                        conpassword.textAlignment = NSTextAlignmentLeft;
                        conpassword.userInteractionEnabled = YES;
                        conpassword.secureTextEntry = YES;
                        conpassword.layer.masksToBounds = true;
                        conpassword.placeholder = NSLocalizedString(@"Re-enter Password", nil);
                        
                        [cell.contentView addSubview:conpassword];
                    }
                        break;
                    default:
                        break;
                }
            }
            break;
            
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"Change Password", nil);
            break;
            
        default:
            break;
    }
    return sectionName;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
