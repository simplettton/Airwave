//
//  ServerIPViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ServerIPViewController.h"
#import "SVProgressHUD.h"
static NSString * SERVERIP_KEY = @"ServerIp";
@interface ServerIPViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)save:(id)sender;
@end

@implementation ServerIPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *serverIp = [userDefault objectForKey:SERVERIP_KEY];
    self.textField.text = serverIp;
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (IBAction)save:(id)sender
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.textField.text forKey:SERVERIP_KEY];
    [userDefault synchronize];
    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    [SVProgressHUD dismissWithDelay:0.9];
}
@end
