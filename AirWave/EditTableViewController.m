//
//  EditTableViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/17.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EditTableViewController.h"

@interface EditTableViewController ()<UITextFieldDelegate>
{
    NSArray *items;
}
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@end

@implementation EditTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc]init];
    //tableview group样式 section之间的高度调整
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    
    //设置内容
    self.title = [NSString stringWithFormat:@"设置%@",self.editKey];
    self.contentTextField.text = self.editValue;
    
    items = [NSArray arrayWithObjects:@"headPhoto",@"name",@"sex",@"age",@"phoneNumber",@"address", nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (IBAction)save:(id)sender
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *newValue = self.contentTextField.text;
    [userDefault setObject: newValue forKey:[items objectAtIndex:self.selectedRow]];
    [userDefault synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    self.returnBlock(self.selectedRow, self.contentTextField.text);
}

#pragma mark - textField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
