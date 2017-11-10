//
//  LeftDrawerViewController.m
//  
//
//  Created by Macmini on 2017/11/7.
//
//

#import "LeftDrawerViewController.h"
#import "LeftHeaderView.h"
#import "DetailViewController.h"
#import "RecordTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "BaseHeader.h"
#import "PersonalInfomationViewController.h"
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
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
    [self addTableHeaderViewAndTableFooterView];
}
#pragma mark --加载View
-(void)addTableHeaderViewAndTableFooterView
{
    LeftHeaderView * headerView = [[LeftHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 75 , 444 * KScreenUnit)];
    [ headerView.myInformationButton addTarget:self action:@selector(buttonClickListener:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headerView;
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
    if (indexPath.row==6)
    {
        cell.textLabel.textColor = UIColorFromHex(0X65BBA9);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row==0){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_business"];
        cell.textLabel.text=@"空气波治疗记录";
    }else if (indexPath.row==1){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_purse"];
        cell.textLabel.text=@"血瘘治疗仪治疗记录";
    }else if (indexPath.row==2){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_decoration"];
        cell.textLabel.text=@"我的服务器IP地址";
    }else if (indexPath.row==3){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_favorit"];
        cell.textLabel.text=@"我的收藏";
    }else if (indexPath.row==4){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_album"];
        cell.textLabel.text=@"我的相册";
    }else if (indexPath.row == 5){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }else if (indexPath.row==6){
        cell.imageView.image=[UIImage imageNamed:@"sidebar_file"];
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text=@"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
    UIViewController *showVC;
    RecordTableViewController *recordVC =(RecordTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"RecordTableViewController"];
    if (indexPath.row == 0)
    {
        recordVC.type = AIRWAVETYPE;
        showVC = recordVC;
    }else if (indexPath.row==1)
    {
        recordVC.type = BLOODDEVTYPE;
        showVC = recordVC;
    }
    
    UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
    [nav pushViewController:showVC animated:NO];
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];

}
-(void)buttonClickListener:(UIButton *)sender
{
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalInfomationViewController *showVC = [mainStoryborad instantiateViewControllerWithIdentifier:@"PersonalInfomationViewController"];
    
    UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
    [nav pushViewController:showVC animated:NO];
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
}

@end
