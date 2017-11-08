//
//  LeftDrawerViewController.m
//  
//
//  Created by Macmini on 2017/11/7.
//
//

#import "LeftDrawerViewController.h"
#import "LeftTableView.h"
#import "LeftHeaderTableView.h"
#import "DetailViewController.h"
#import "BaseHeader.h"

@interface LeftDrawerViewController ()
//@property (weak, nonatomic) IBOutlet LeftTableView *tableView;
@property (strong,nonatomic)LeftTableView *tableView;
@property(assign , nonatomic) int homePageIndex;
@end

@implementation LeftDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackground];
    [self addTableView];
}

-(void)addTableView
{
    self.tableView = [[LeftTableView alloc] initWithFrame:CGRectMake(0, 0, 260,  [UIScreen mainScreen].bounds.size.height )];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    NSLog(@"self.tableView = %@",self.tableView);
    [self.view addSubview:self.tableView];
}
-(void)setBackground
{
    self.view.backgroundColor =  [UIColor whiteColor];
    UIImageView * mengban = [[UIImageView alloc] initWithFrame:self.view.frame];
    mengban.backgroundColor = UIColorFromRGBAndAlpha(0x000000, 1);
    mengban.alpha = 0.25;
    [self.view addSubview:mengban];

}
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
////
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 2;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"leftDrawerCell" forIndexPath:indexPath];
//    UILabel *label = [cell viewWithTag:1000];
//    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//    return cell;
//}


//#pragma mark -- LeftTableViewClickDelegate
//-(void)tableView:(UITableView *)tableView clickedType:(ELeftClickType)clickType{
//    UIViewController * viewController;
//    switch (clickType) {
//        case KMyInformation:
//            viewController = [[DetailViewController alloc] init];
//            break;
//        case KQRCode:
//            viewController = [[DetailViewController alloc] init];
//            break;
//        case KPersonalSignature:
//            viewController = [[DetailViewController alloc] init];
//            break;
//        case KMyQQVip:
//            viewController = [[DetailViewController alloc] init];
//            break;
//        case KQQWalte:
//            viewController = [[DetailViewController alloc] init];
//            break;
////        case KPersonalDressing:
////            viewController = [[OtherViewController alloc] init];
////            break;
////        case KMyLike:
////            viewController = [[OtherViewController alloc] init];
////            break;
////        case KMyAlbum:
////            viewController = [[OtherViewController alloc] init];
////            break;
////        case KMyFile:
////            viewController = [[OtherViewController alloc] init];
////            break;
//        case KAppSeting:
//            
//            break;
//        case KNightStyle:
//            
//            break;
//        case KWeather:
//            
//            break;
//        default:
//            break;
//    }
//    [self notificationHomePagePushViewController:viewController];
//}
//#pragma mark -- 点击事件跳转
//-(void)notificationHomePagePushViewController:(UIViewController *) viewController{
//    
//    //[appDelegate.mainTabBarViewController.messageViewController.navigationController pushViewController:otherViewController animated:YES];
//    //    3. 抽屉栏点击事件后需要跳转页面，关闭抽屉， 通过HomePage+index+push名通知主页push，内容需要push的vc。
//    if (viewController)
//    {
//        NSString * postName = [NSString stringWithFormat:@"HomePage%dPush",self.homePageIndex];
//        [[NSNotificationCenter defaultCenter] postNotificationName:postName object:nil userInfo:@{@"pushViewController":viewController}];
//    }
//    
//}
//#pragma make -- MainTabChanged通知事件
//-(void)mainTabChanged:(NSNotification *) notification{
//    NSDictionary * dict = notification.userInfo;
//    self.homePageIndex = [dict[@"selectedIndex"] intValue];
//}

@end
