//
//  EditProductViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/15.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import "EditProductViewController.h"
#import "CNPPopupController.h"

@interface EditProductViewController () <CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation EditProductViewController
@synthesize productsku, productdata, productname, productprice, productquantity;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"sku %@ - %@", productsku, productname);
    self.navigationController.navigationItem.title = [NSString stringWithFormat:@"%@", productname];
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    maintable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, curwidth, curheigh) style:UITableViewStyleGrouped];
    maintable.delegate = self;
    maintable.dataSource = self;
    [maintable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.navigationItem.title = NSLocalizedString(productname, nil);
    [self.view addSubview:maintable];
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
    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *ViewCellIdentifier = @"ViewCell";
    UITableViewCell *cell = nil;
    cell = [maintable dequeueReusableCellWithIdentifier:ViewCellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
            case 0:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            inputnamefield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            inputnamefield.leftView = paddingview;
            inputnamefield.delegate = self;
            inputnamefield.tag = 0;
            inputnamefield.keyboardType = UIKeyboardTypeASCIICapable;
            inputnamefield.leftViewMode = UITextFieldViewModeAlways;
            inputnamefield.placeholder = @"Name";
            
            inputnamefield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            inputnamefield.layer.borderWidth = 0.5f;
            inputnamefield.tag = 1;
            [inputnamefield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:inputnamefield];
        }
            break;
            case 1:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            skufield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            skufield.leftView = paddingview;
            skufield.delegate = self;
            skufield.tag = 1;
            skufield.keyboardType = UIKeyboardTypeASCIICapable;
            skufield.textColor = [UIColor blackColor];
            skufield.leftViewMode = UITextFieldViewModeAlways;
            skufield.placeholder = @"SKU";
            skufield.adjustsFontSizeToFitWidth = YES;
            skufield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            skufield.layer.borderWidth = 0.5f;
            skufield.tag = 2;
            
            UIButton *scanbarcode = [UIButton buttonWithType:UIButtonTypeCustom];
            scanbarcode.frame = CGRectMake(skufield.frame.size.width-40, 5, 30, 30);
            [scanbarcode setTitle:@"" forState:UIControlStateNormal];
            [scanbarcode addTarget:self action:@selector(scancode:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *scancodeview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanbarcode.frame.size.width, scanbarcode.frame.size.height)];
            scancodeview.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *scancodeimg = [UIImage imageNamed:@"Camera-icon.png"];
            [scancodeview setImage:scancodeimg];
            [scanbarcode addSubview:scancodeview];
            [skufield addSubview:scanbarcode];
            [skufield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:skufield];
        }
            break;
            case 2:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            pricefield = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            pricefield.leftView = paddingview;
            pricefield.delegate = self;
            pricefield.tag = 3;
            pricefield.keyboardType = UIKeyboardTypeDecimalPad;
            pricefield.leftViewMode = UITextFieldViewModeAlways;
            pricefield.placeholder = @"Price";
            pricefield.layer.borderColor = [UIColor lightGrayColor].CGColor;
            pricefield.layer.borderWidth = 0.5f;
            pricefield.tag = 3;
            
            [pricefield addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:pricefield];
        }
            break;
            case 3:
        {
            UIView *paddingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
            
            receivestock = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, curwidth-20, 40)];
            receivestock.leftView = paddingview;
            receivestock.delegate = self;
            receivestock.tag = 4;
            receivestock.keyboardType = UIKeyboardTypeNumberPad;
            receivestock.leftViewMode = UITextFieldViewModeAlways;
            receivestock.placeholder = @"Received Stock";
            receivestock.layer.borderColor = [UIColor lightGrayColor].CGColor;
            receivestock.layer.borderWidth = 0.5f;
            receivestock.tag = 4;
            
            [receivestock addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            [cell.contentView addSubview:receivestock];
        }
            break;
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
