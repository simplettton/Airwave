//
//  RecordReportViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordReportViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface RecordReportViewController ()
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *reportDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *suggestTextField;
@property (weak, nonatomic) IBOutlet UIView *photoView;

@end

@implementation RecordReportViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    self.navigationController.navigationBar.hidden = YES;
//    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0x65BBA9);
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //补全所有边框线
    self.addressTextView.layer.borderWidth = 0.8;
    self.headerImageView.layer.borderWidth = 0.8;
    self.suggestTextField.layer.borderWidth = 0.8;
    self.photoView.layer.borderWidth = 0.8;
    self.addressTextView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.headerImageView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.suggestTextField.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.photoView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //关闭按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = barButton;
    
    //报告时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy/MM/dd";
    self.reportDateLabel.text = [formatter stringFromDate:[NSDate date]]    ;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}
- (void)closeSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
