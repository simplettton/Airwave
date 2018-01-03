//
//  LeftDrawerViewController.m
//  
//
//  Created by Macmini on 2017/11/7.
//
//

#import "LeftDrawerViewController.h"
#import "BaseHeader.h"
#import "LoginViewController.h"
#import "DetailViewController.h"
#import "ServerIPViewController.h"
#import "RecordTableViewController.h"
#import "PersonalInfomationViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "AirWaveNetworkSettingViewController.h"


NSString * const AIRWAVETYPE = @"7681";
NSString * const BLOODDEVTYPE = @"8888";

NSString * const SERVERIP_KEY = @"ServerIp";
NSString * const SERVER_IP = @"http://218.17.22.131:3088";
@interface LeftDrawerViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(assign , nonatomic) int homePageIndex;
@end

@implementation LeftDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
//    [self addTableHeaderViewAndTableFooterView];
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:SERVER_IP])
    {
        [userDefault setObject:SERVER_IP forKey:SERVERIP_KEY];
    }
    [userDefault synchronize];
    
    [ self.headerView.myInformationButton addTarget:self action:@selector(buttonClickListener:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{

    UILabel *textLabel = [cell viewWithTag:2];
    if (indexPath.row==6)
    {
        textLabel.textColor = UIColorFromHex(0X65BBA9);
        textLabel.textAlignment = NSTextAlignmentCenter;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *textLabel = [cell viewWithTag:2];
    if (indexPath.row==0){
        imageView.image = [UIImage imageNamed:@"form1"];
        textLabel.text = @"空气波治疗记录";
    }else if (indexPath.row==1){
        imageView.image = [UIImage imageNamed:@"form"];
        textLabel.text = @"血瘘治疗仪治疗记录";
    }else if (indexPath.row==2){
        imageView.image=[UIImage imageNamed:@"ip"];
        textLabel.text=@"我的服务器IP地址";
    }else if (indexPath.row==3){
        imageView.image=[UIImage imageNamed:@"internet"];
        textLabel.text=@"空气波网络配置";
    }else if (indexPath.row==4){
        imageView.image=[UIImage imageNamed:@"pic"];
        textLabel.text=@"我的相册";
    }else if (indexPath.row == 5){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }else if (indexPath.row==6){
        imageView.image=[UIImage imageNamed:@"sidebar_file"];
        textLabel.text=@"退出登录";
        textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.textColor=[UIColor blackColor];
    //    cell.selectedBackgroundView = [[UIImageView alloc] init];
    //    cell.selectedBackgroundView.backgroundColor = UIColorFromRGBAndAlpha(0xffffff, 0.3);
    //    点击cell时没有点击效果
    //    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __block UIViewController *showVC;
    RecordTableViewController *recordVC =(RecordTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"RecordTableViewController"];

    if (indexPath.row == 0)
    {
        recordVC.type = AIRWAVETYPE;
        showVC = recordVC;
    }else if (indexPath.row == 1)
    {
        recordVC.type = BLOODDEVTYPE;
        showVC = recordVC;
    }else if (indexPath.row == 2)
    {
        ServerIPViewController *serverVC = (ServerIPViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"ServerIPViewController"];
        showVC = serverVC;
    }else if(indexPath.row == 3)
    {
        AirWaveNetworkSettingViewController *networkSettingVC = (AirWaveNetworkSettingViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"AirWaveNetworkSettingViewController"];
        showVC = networkSettingVC;
    }else if (indexPath.row == 6)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"您确定要退出登录吗？"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"立即退出"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
            LoginViewController *loginVC = (LoginViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"LoginViewController"];
            showVC = loginVC;
                                                                 
            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
            [nav pushViewController:showVC animated:YES];
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
            {
              [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
              
            
        }];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (showVC)
    {
        UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
        [nav pushViewController:showVC animated:NO];
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
         {
             [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
         }];
    }


}
-(void)buttonClickListener:(UIButton *)sender
{
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalInfomationViewController *showVC = [mainStoryborad instantiateViewControllerWithIdentifier:@"PersonalInfomationViewController"];
    
    UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
    [nav pushViewController:showVC animated:NO];
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
    {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
}

@end
