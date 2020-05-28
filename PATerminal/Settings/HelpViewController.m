//
//  HelpViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/04/13.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "HelpViewController.h"
#import "writefiles.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
@synthesize tableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Help", nil);
    standardUser = [NSUserDefaults standardUserDefaults];
    
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    tableview.delegate = self;
    tableview.dataSource = self;
    
    [self.view addSubview:tableview];
}

-(void)viewDidAppear:(BOOL)animated
{
    writefileclass = [[writefiles alloc] init];
    //writefileclass.updatelocation = [standardUser objectForKey:@"lastlocation"];
    [writefileclass setpageview:@"help.view"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table view methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [tableview dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Contact Alipay Support", nil);
            cell.detailTextLabel.text = @"+852 2245 3201";
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Contact PA Pay Support", nil);
            cell.detailTextLabel.text = @"+852 2207 3185";
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Contact PA Pay Support Via WhatsApp", nil);
            cell.detailTextLabel.text = @"+852 9168 7234";
            break;
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"Learn More", nil);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            {
                NSURL *phoneURL = [NSURL URLWithString:@"telprompt:+85222453201"];
                [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:^(BOOL success){
                    if (success) {
                        NSLog(@"Success");
                    }
                }];
            }
            break;
        case 1:
            {
                NSURL *phoneURL = [NSURL URLWithString:@"telprompt:+85222073185"];
                [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:^(BOOL success){
                    if (success) {
                        NSLog(@"Success");
                    }
                }];
            }
            break;
        case 2:
        {
            NSURL *phoneURL = [NSURL URLWithString:@"https://api.whatsapp.com/send?phone=85291687234"];
            [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:^(BOOL success){
                if (success) {
                    NSLog(@"Success");
                }
            }];
//            [[UIApplication sharedApplication] openURL:phoneURL];
        }
        default:
            break;
    }
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
