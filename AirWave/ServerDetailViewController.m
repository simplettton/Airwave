//
//  ServerDetailViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/24.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ServerDetailViewController.h"
#import "ServerReportViewController.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface ServerDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *mode;
@property (weak, nonatomic) IBOutlet UILabel *treatTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *modeOrLevelLabel;
@end
@implementation ServerDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x65BBA9);
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self.dic objectForKey:@"Id"] forKey:@"Id"];
    
    [[HttpHelper instance] post:@"getimg"
                         params:params
                       hasToken:NO
                     onResponse:^(HttpResponse *responseObject)
     {
         NSDictionary* jsonDict = [responseObject jsonDist];
         CGFloat width=[UIScreen mainScreen].bounds.size.width;
         CGFloat height=[UIScreen mainScreen].bounds.size.height;
         if (jsonDict !=nil)
         {
             int state = [[jsonDict objectForKey:@"State"] intValue];
             if (state==1)//有图片
             {
                 NSString *imageString = [jsonDict objectForKey:@"Img"];
                 NSData *nsdataFromBase64String = [[NSData alloc]
                                                   initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.scrollView.contentSize = CGSizeMake(width, 1100);
                     self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                     self.imageView.image = [[UIImage alloc]initWithData:nsdataFromBase64String];
                 });
             }
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.scrollView.contentSize = CGSizeMake(width, height);
             });
         }
     }
                        onError:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";

    self.name.text = [NSString stringWithFormat:@"  %@",[self.dic objectForKey:@"Name"]];
    self.sex.text = [NSString stringWithFormat:@"  %@",[self.dic objectForKey:@"Sex"]];
    self.age.text = [NSString stringWithFormat:@"  %@",[self.dic objectForKey:@"Age"]];
    self.phone.text = [NSString stringWithFormat:@"  %@",[self.dic objectForKey:@"Phone"]];
    self.address.text = [NSString stringWithFormat:@"  %@",[self.dic objectForKey:@"Address"]];
    NSString *dateString = [self.dic objectForKey:@"Date"];
    self.date.text = [NSString stringWithFormat:@"  %@",[self timeWithTimeIntervalString:dateString]];
    NSString *treatWayString= @"";
    if ([[self.dic objectForKey:@"Type" ]isEqualToString:BLOODDEVTYPE])
    {
        self.modeOrLevelLabel.text = @"治疗强度";
        treatWayString = [NSString stringWithFormat:@"%d",[[self.dic objectForKey:@"Mode"]intValue]];
    }
    else
    {
        switch ([[self.dic objectForKey:@"Mode"]intValue])
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
    }
    self.mode.text = [NSString stringWithFormat:@"  %@",treatWayString];
    self.treatTime.text = [NSString stringWithFormat:@"  %@",[self convertTimeWithSecond:[self.dic objectForKey:@"Treattime"]]];
    
    //查看报告按钮
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

}
#pragma mark - private method
- (NSString *)convertTimeWithSecond:(NSString *)string
{

    int duration = [string intValue];
    int hour = duration / 3600;
    int min = (duration / 60)%60;
    int second = duration % 60;
    
    //治疗时间为两位数
    NSString *hourString = [NSString stringWithFormat:hour>9?@"%d":@"0%d",hour];
    NSString *minString = [NSString stringWithFormat:min>9?@"%d":@"0%d",min];
    NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
    NSString *durationString = @"";
    if (hour>0)
    {
        durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%@小时",hourString]];
    }
    if (min>0)
    {
        durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%@分钟",minString]];
    }
    if (second>0)
    {
        durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%@秒",secondString]];
    }

    return durationString;
}
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH分mm秒"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowServerReport"])
    {
        ServerReportViewController *vc = (ServerReportViewController *)segue.destinationViewController;
        vc.dic = self.dic;
        vc.type = self.type;
    }
}

@end
