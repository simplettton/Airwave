//
//  RecordReportViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordReportViewController.h"

@interface RecordReportViewController ()

@end

@implementation RecordReportViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
