//
//  ServerReportViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/16.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ServerReportViewController.h"
#import "ZWGraphicView.h"
#import "BEPresentView.h"
#import "SVProgressHUD.h"
#import "XWScanImage.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
#define ScreenW self.view.bounds.size.width
#define ScreenH self.view.bounds.size.height
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface ServerReportViewController ()
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UITextView *suggestTextView;
@property (weak, nonatomic) IBOutlet UILabel *reportDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeOrLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *devTitleLabel;


@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signImageView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong ,nonatomic) UIImage *signImage;
@property (weak, nonatomic) IBOutlet UIView *photoView;


@end

@implementation ServerReportViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0x65BBA9);
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //补全所有边框线
    self.addressTextView.layer.borderWidth = 0.8;
    self.headerImageView.layer.borderWidth = 0.8;
    self.suggestTextView.layer.borderWidth = 0.8;
    self.photoView.layer.borderWidth = 0.8;
    
    self.addressTextView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.headerImageView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.suggestTextView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    self.photoView.layer.borderColor = UIColorFromHex(0x333333).CGColor;
    
    //获取图片
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self.dic objectForKey:@"Id"] forKey:@"Id"];
    
    [[HttpHelper instance] post:@"getimg"
                         params:params
                       hasToken:NO
                     onResponse:^(HttpResponse *responseObject)
     {
         NSDictionary* jsonDict = [responseObject jsonDist];
         if (jsonDict !=nil)
         {
             int state = [[jsonDict objectForKey:@"State"] intValue];
             if (state==1)//有图片
             {
                 NSString *imageString = [jsonDict objectForKey:@"Img"];
                 

                 NSData *nsdataFromBase64String = [[NSData alloc]
                                                   initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //图片添加点击放大手势
                     UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanBigImageClick:)];
                     [self.resultImageView addGestureRecognizer:tapGestureRecognizer];
                     [self.resultImageView setUserInteractionEnabled:YES];
                     self.resultImageView.image = [[UIImage alloc]initWithData:nsdataFromBase64String];
                 });
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 35, 18, 21)];
                     label.text = @"无";
                     label.textColor = UIColorFromHex(0x333333);
                     label.font = [UIFont systemFontOfSize:14];
                     [self.photoView addSubview:label];
                 });
             }
         }

     }
                        onError:nil];
    
    //获取签名
    [[HttpHelper instance] post:@"getsign"
                         params:params
                       hasToken:NO
                     onResponse:^(HttpResponse *responseObject)
     {
         NSDictionary* jsonDict = [responseObject jsonDist];
         if (jsonDict !=nil)
         {
             int state = [[jsonDict objectForKey:@"State"] intValue];
             if (state==1)//签名
             {
                 //签名
                 NSString *imageString = [jsonDict objectForKey:@"Img"];
                 NSData *nsdataFromBase64String = [[NSData alloc]
                                                   initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];

                 //报告时间
                 NSString *dateString = [jsonDict objectForKey:@"Date"];
                 dispatch_async(dispatch_get_main_queue(), ^{
                    self.signImageView.image = [[UIImage alloc]initWithData:nsdataFromBase64String];
                    self.reportDateLabel.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:dateString format:@"yyyy/MM/dd"]];
                 });
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSDate *date = [NSDate date];
                     NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                     [formatter setDateFormat:@"yyyy/MM/dd"];
                     self.reportDateLabel.text = [formatter stringFromDate:date];
                 });
             }
         }
         
     }
                    onError:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"DIC = %@",self.dic);
    //关闭按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = barButton;
    
    //设置图片自动缩放
    self.signImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //设置图片居中显示
    [self.resultImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.resultImageView.contentMode =  UIViewContentModeScaleAspectFill;
    self.resultImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.resultImageView.clipsToBounds  = YES;
    
    

    //配置界面内容
    self.nameLabel.text = [NSString stringWithFormat:@"%@",[self.dic objectForKey:@"Name"]];
    self.sexLabel.text = [NSString stringWithFormat:@"%@",[self.dic objectForKey:@"Sex"]];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",[self.dic objectForKey:@"Age"]];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@",[self.dic objectForKey:@"Phone"]];
    self.addressTextView.text = [NSString stringWithFormat:@"%@",[self.dic objectForKey:@"Address"]];
    
    NSString *dateString = [self.dic objectForKey:@"Date"];
    self.treatDateLabel.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:dateString format:@"yyyy年MM月dd日 HH时mm分"]];
    NSString *treatWayString= @"";
    if ([[self.dic objectForKey:@"Type" ]isEqualToString:BLOODDEVTYPE])
    {
        self.modeOrLevelLabel.text = @"治疗强度";
        self.devTitleLabel.text = @"血瘘治疗仪治疗数据";
        treatWayString = [NSString stringWithFormat:@"%d",[[self.dic objectForKey:@"Mode"]intValue]];
        switch ([[self.dic objectForKey:@"Mode"]intValue]) {
            case 1:
                treatWayString = @"一级";
                break;
            case 2:
                treatWayString = @"二级";
                break;
            case 3:
                treatWayString = @"三级";
                break;
            default:
                break;
        }
    }
    else
    {
        self.modeOrLevelLabel.text = @"治疗模式";
        self.devTitleLabel.text = @"空气波治疗仪治疗数据";
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
//                treatWayString = @"标准治疗";
                break;
        }
    }
    self.treatWayLabel.text = [NSString stringWithFormat:@"%@",treatWayString];
    self.treatTimeLabel.text = [NSString stringWithFormat:@"%@",[self convertTimeWithSecond:[self.dic objectForKey:@"Treattime"]]];
    
    NSString *suggestString = [self.dic objectForKey:@"Suggest"];
    if ([suggestString isEqualToString:@""]||suggestString == nil)
    {
        self.suggestTextView.text = @"无";
    }
    else
    {
        self.suggestTextView.text = [self.dic objectForKey:@"Suggest"];
    }

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
//        NSInteger index=[[self.navigationController viewControllers]indexOfObject:self];
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
}

#pragma mark - 放大图片
-(void)scanBigImageClick:(UITapGestureRecognizer *)tap
{
    
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    if (clickedImageView)
    {
        [XWScanImage scanBigImageWithImageView:clickedImageView];
    }

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

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString format:(NSString *)format
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}



@end
