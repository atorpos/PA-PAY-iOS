//
//  ReportViewController.m
//  PATerminal
//
//  Created by Oskar Wong on 5/19/20.
//  Copyright © 2020 Oskar Wong. All rights reserved.
//

#import "ReportViewController.h"
#import "PATerminal-Swift.h"

@import Charts;
@interface ReportViewController () <ChartDataProvider, ChartViewDelegate>

@property (nonatomic, strong) IBOutlet LineChartView *lineview;

@end


@implementation ReportViewController
@synthesize chartXMax, chartXMin, chartYMax, chartYMin, centerOffsets, data, maxVisibleCount, maxHighlightDistance, xRange;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    curwidth = [UIScreen mainScreen].bounds.size.width;
    curheigh = [UIScreen mainScreen].bounds.size.height;
    CGFloat toppadding = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.top;
    CGFloat bottompadding = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    UINavigationController *navbar = [[UINavigationController alloc] init];
    CGFloat navbarheight = navbar.navigationBar.frame.size.height;
    
    standardef = [NSUserDefaults standardUserDefaults];
    mainview = [[UIView alloc] initWithFrame:CGRectMake(0, toppadding+navbarheight, curwidth, curheigh-toppadding-bottompadding+navbarheight)];
    mainview.backgroundColor = [UIColor whiteColor];
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, mainview.frame.size.height/3, curwidth, 2*mainview.frame.size.height/3)];
    tableview.backgroundColor = [UIColor whiteColor];
    
    
    systemurl = @"https://merchant.pa-sys.com/terminal-summary/weekly-get";
    [self.view addSubview:mainview];
    [mainview addSubview:tableview];
}

-(void)viewDidAppear:(BOOL)animated {
    
    
    NSString *posttoken = [NSString stringWithFormat:@"token=%@", [standardef objectForKey:@"signtoken"]];
    NSData *postdata = [posttoken dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *stringlength = [NSString stringWithFormat:@"%lu", (unsigned long)[posttoken length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:systemurl]];
    [request setHTTPMethod:@"POST"];
    [request setValue:stringlength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postdata];
    [request setTimeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response &&! error) {
            NSString *newstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"back requeste %@", newstr);
                [self performSelectorOnMainThread:@selector(fetchdata:) withObject:data waitUntilDone:YES];
        } else {
        }
    }];
    
    [task resume];
}
-(void)fetchdata:(NSData *)requestdata {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:requestdata options:kNilOptions error:&error];
    max_value = [[[json objectForKey:@"payload"] objectAtIndex:0] objectForKey:@"max"];
    week_total =[[[json objectForKey:@"payload"] objectAtIndex:0] objectForKey:@"week_total"];
    NSDictionary *thechartdata = [[[[json objectForKey:@"payload"] objectAtIndex:0] objectForKey:@"transactions_detail"] objectForKey:@"success"];
//    max_value = [[json objectForKey:@"payload"] objectForKey:@"max"];
    NSLog(@"show chart %@", thechartdata);
    [self showgraphic:thechartdata];
}

-(void)showgraphic:(NSDictionary *)dictioanry {
    
    NSArray *keyarray = [dictioanry allKeys];
    
    NSMutableArray *transactionarray = [[NSMutableArray alloc] init];
    NSMutableArray *amountarray = [[NSMutableArray alloc] init];
    for (int i=0; i<[keyarray count]; i++) {
//        double amountval = [[[dictioanry objectForKey:[keyarray objectAtIndex:i]] objectForKey:@"amount"] doubleValue];
        
//        [transactionarray addObject:[[dictioanry objectForKey:[keyarray objectAtIndex:i]] objectForKey:@"count"]];
//        [amountarray addObject:[[dictioanry objectForKey:[keyarray objectAtIndex:i]] objectForKey:@"amount"]];
        [amountarray addObject:[[BarChartDataEntry alloc] initWithX:i y:[[[dictioanry objectForKey:[keyarray objectAtIndex:i]] objectForKey:@"amount"] doubleValue]]];
    }
    NSLog(@"show amount array %@", amountarray);
    BarChartView *barview = [[BarChartView alloc] init];
    barview.frame = CGRectMake(0, 0, mainview.frame.size.width, mainview.frame.size.height/3);
    barview.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
    barview.chartDescription.enabled = YES;
    barview.drawGridBackgroundEnabled = YES;
    barview.dragEnabled = NO;
    [barview setScaleEnabled:NO];
    barview.pinchZoomEnabled = NO;
    barview.delegate = self;
    barview.drawBarShadowEnabled = NO;
    barview.drawValueAboveBarEnabled = YES;
    barview.maxVisibleCount = 20;
    
    ChartXAxis *xAxis = barview.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 3;
    leftAxisFormatter.negativeSuffix = @" $";
    leftAxisFormatter.positiveSuffix = @" $";
    
    ChartYAxis *yAxis = barview.leftAxis;
    yAxis.labelPosition = YAxisLabelPositionOutsideChart;
    yAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    
    BarChartDataSet *set1 = nil;
    
    set1 = [[BarChartDataSet alloc] initWithEntries:amountarray label:@"Amount"];
    set1.drawIconsEnabled = NO;
    
    set1.highlightLineDashLengths = @[@5.f, @2.5f];
    [set1 setColors:ChartColorTemplates.joyful];
    
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.formLineDashLengths = @[@5.f, @2.5f];
    set1.formLineWidth = 1.0;
    set1.formSize = 15.0;
    
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    

    
    CGGradientRelease(gradient);
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    
    barview.data = data;
    
    [mainview addSubview:barview];
    
    [barview setNeedsDisplay];
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
