//
//  ServerRecordTableViewController.m
//  demo
//
//  Created by Macmini on 2017/10/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ServerRecordTableViewController.h"
#import "ServerDetailViewController.h"
#import "DetailViewController.h"
#import "RecordTableViewCell.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const TYPE = @"7681";

@interface ServerRecordTableViewController ()
{
    NSMutableArray *datas;
    NSInteger currentPage;
    NSInteger numberOfPages;
}
- (IBAction)nextPage:(id)sender;
- (IBAction)previousPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *upButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downButton;

@end

@implementation ServerRecordTableViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self startRequest];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.upButton.enabled = NO;
    self.tableView.tableFooterView = [[UIView alloc]init];
    //navigation
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xffffff);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xffffff);
}

-(void)startRequest
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)currentPage] forKey:@"Page"];
    [params setObject:TYPE forKey:TYPE];
    //获取总数
    [[HttpHelper instance] post:@"count"
                         params:@{@"Type":TYPE}
                       hasToken:NO
                     onResponse:^(HttpResponse *responseObject) {
                         NSDictionary* jsonDict = [responseObject jsonDist];
                         if (jsonDict !=nil)
                         {
                             //记录总量
                             int Sum = [[jsonDict objectForKey:@"Sum"]intValue];
                             numberOfPages = (Sum+10-1)/10;

                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 //获取数据
                                 [[HttpHelper instance] post:@"get"
                                                      params:params
                                                    hasToken:NO
                                                  onResponse:^(HttpResponse *responseObject) {
                                                      NSDictionary* jsonDict = [responseObject jsonDist];
                                                      if (jsonDict !=nil)
                                                      {
                                                          datas = [[NSMutableArray alloc]initWithCapacity:20];
                                                          for(NSDictionary *dic in jsonDict)
                                                          {
                                                              [datas addObject:dic];
                                                          }
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.tableView reloadData];
                                                          });
                                                      }
                                                  }
                                                    onError:nil];
                             });
                         }
                     }
                        onError:nil];
}

-(void)getData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)currentPage] forKey:@"Page"];
    //获取数据
    [[HttpHelper instance] post:@"get"
                         params:params
                       hasToken:NO
                     onResponse:^(HttpResponse *responseObject) {
                         NSDictionary* jsonDict = [responseObject jsonDist];
//                         NSLog(@"get = %@ ",jsonDict);
                         if (jsonDict !=nil)
                         {
                             datas = [[NSMutableArray alloc]initWithCapacity:20];
                             for(NSDictionary *dic in jsonDict)
                             {
                                 [datas addObject:dic];
                             }
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.tableView reloadData];
                             });
                             
                             
                         }
                     }
                        onError:nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[RecordTableViewCell init]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([datas count]>0)
    {
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row +1];
        NSString *treatWayString= @"";
        switch ([[datas[indexPath.row]objectForKey:@"Mode"]intValue])
        {
            case 1:
                treatWayString = @"标准治疗";
                break;
            case 2:
                treatWayString = @"梯度治疗";
                break;
            case 3:
                treatWayString = @"参数治疗";
                break;
            case 4:
                treatWayString = @"方案治疗";
                break;
            default:
                treatWayString = @"标准治疗";
                break;
        }
        cell.treatWayLabel.text = [NSString stringWithFormat:@"%@",treatWayString];
        NSString *str3 = [datas[indexPath.row]objectForKey:@"Name"];
        NSString *str5 = [str3 stringByRemovingPercentEncoding];
        cell.timeLabel.text = [NSString stringWithFormat:@"name : %@",str5];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowServerDetail" sender:datas[indexPath.row]];
}
- (IBAction)nextPage:(id)sender
{
    if (currentPage != numberOfPages -1)
    {
        self.downButton.enabled = YES;
        currentPage = currentPage +1;
        if (currentPage == numberOfPages -1)
        {
            self.downButton.enabled = NO;
        }
    }
    else{
        self.downButton.enabled = NO;
    }
    
    if (currentPage !=0 )
    {
        self.upButton.enabled = YES;
    }
    [self getData];
}

- (IBAction)previousPage:(id)sender
{
    if (currentPage !=0 )
    {
       self.upButton.enabled = YES;
       currentPage = currentPage -1;
        if (currentPage == 0)
        {
            self.upButton.enabled = NO;
        }
    }else
    {
        self.upButton.enabled = NO;
    }
    
    if (currentPage != numberOfPages -1)
    {
        self.downButton.enabled = YES;
    }
    [self getData];

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowServerDetail"])
    {
        ServerDetailViewController *viewController = (ServerDetailViewController *)segue.destinationViewController;
        viewController.dic = sender;
    }
}

@end
