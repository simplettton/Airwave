//
//  AirWaveNetworkSettingViewController.m
//  AirWave
//
//  Created by Macmini on 2017/12/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
      
#import "AirWaveNetworkSettingViewController.h"
#import "AppDelegate.h"
#import <SVProgressHUD.h>

@interface AirWaveNetworkSettingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
- (IBAction)save:(id)sender;

@end

@implementation AirWaveNetworkSettingViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.sectionFooterHeight = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.hostTextField.text = myDelegate.host;
    self.portTextField.text = myDelegate.port;
    
    self.portTextField.delegate = self;
    self.hostTextField.delegate = self;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (IBAction)save:(id)sender
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    myDelegate.host = self.hostTextField.text;
    myDelegate.port = self.portTextField.text;
    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    [SVProgressHUD dismissWithDelay:0.9];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
