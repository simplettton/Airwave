//
//  PersonalInfomationViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/10.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PersonalInfomationViewController.h"
#import "EditTableViewController.h"
#import "BaseHeader.h"
@interface PersonalInfomationViewController ()
{
    NSArray *keys;
}
@property (strong,nonatomic) IBOutletCollection(UITableViewCell)NSArray *cells;

@end

@implementation PersonalInfomationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    //tableview group样式 section之间的高度调整
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    keys = [NSArray arrayWithObjects:@"headPhoto",@"name",@"sex",@"age",@"phoneNumber",@"address", nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    for (int i = 0;i<[keys count];i++)
    {
        UITableViewCell *cell = [self.cells objectAtIndex:i];
        UIView * valueView = [cell viewWithTag:2];
        if([valueView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)valueView;

            label.text = [userDefault objectForKey:keys[i]];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"个人信息";
    
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0XFFFFFF)}];
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else if(section == 1)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        UITableViewCell *cell = [self.cells objectAtIndex:2];
        UILabel * label = (UILabel *)[cell viewWithTag:2];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"点击取消");
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefault setObject:@"男" forKey:@"sex"];
            [userDefault synchronize];
            label.text = @"男";
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefault setObject:@"女" forKey:@"sex"];
            [userDefault synchronize];
            label.text = @"女";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (( indexPath.section == 0 && indexPath.row != 0)||(indexPath.section == 1))
    {
         [self performSegueWithIdentifier:@"EditInfomation" sender:indexPath];
    }

}
#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditInfomation"])
    {
        EditTableViewController *vc = (EditTableViewController *)segue.destinationViewController;
        
        NSIndexPath *index = (NSIndexPath *)sender;
        UITableViewCell *cell;
        if (index.section ==1)
        {
            cell = [self.cells objectAtIndex:index.row+index.section *5];
        }else
        {
            cell = [self.cells objectAtIndex:index.row];
        }

        UILabel *keyLabel = [cell viewWithTag:1];
        UILabel *valueLabel = [cell viewWithTag:2];
        vc.editKey =keyLabel.text;
        vc.editValue = valueLabel.text;
        vc.selectedRow = index.section *5 + index.row;
        vc.returnBlock = ^(NSInteger changedRow,NSString *newValue)
        {
            UITableViewCell *cell = [self.cells objectAtIndex:changedRow];
            UIView * valueView = [cell viewWithTag:2];
            if([valueView isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)valueView;

                label.text = newValue;
            }
        };
    }
}
@end
