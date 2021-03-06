 //
//  TreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import <GCDAsyncSocket.h>
//获取连接wifi名字的框架
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Pack.h"
#import "BodyButton.h"
#import "TreatViewController.h"
#import "TreatInformation.h"
#import "RunningInfomation.h"
#import "WarnMessage.h"
#import "TreatRecord.h"
#import "UIImage+ImageWithColor.h"
#import "ProgressView.h"

#import "EnumValue.h"

#import "AppDelegate.h"
#import "StandardTreatViewController.h"
#import "GradientTreatViewController.h"
#import "ParameterTreatViewController.h"
#import "SolutionTreatViewController.h"
#import "SettingViewController.h"
#import "RecordTableViewController.h"

#import "SVProgressHUD.h"

#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
static NSString *TYPE = @"7681";
NSString *const HOST = @"10.10.100.254";
NSString *const PORT = @"8080";

@interface TreatViewController ()<GCDAsyncSocketDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, assign) BOOL connected;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;

@property (nonatomic, strong) NSTimer *changeColorTimer;
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) TreatRecord *treatRecord;
@property (nonatomic, strong) TreatInformation *treatInformation;
@property (nonatomic, strong) RunningInfomation *runningInfomation;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *warnningLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (weak, nonatomic) IBOutlet ProgressView *progressView;
@property (weak, nonatomic) IBOutlet ProgressView *progressBackground;

- (IBAction)returnHome:(id)sender;
- (IBAction)tapPlayButton:(id)sender;
- (IBAction)tapPauseButton:(id)sender;
- (IBAction)tapSettingButton:(id)sender;
@end
@implementation TreatViewController
{
    BOOL isPlayButton;
    BOOL isPauseButton;
    NSArray *bodyNames;
    NSArray *legNames;
    NSMutableArray *bodyButtons;
    NSMutableArray *legButtons;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"空气波治疗仪";
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0XFFFFFF)}];
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
    //在前一个界面设置下个界面的返回按钮:self.navigationItem.backBarButtonItem
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.backBarButtonItem = item;

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (myDelegate.cclientSocket != nil)
    {
        self.clientSocket = myDelegate.cclientSocket;
        self.clientSocket.delegate = self;
        self.connected = myDelegate.cconnected;
    }
    [self configureView];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    if (bodyButtons)
    {
        for(UIButton *button in bodyButtons)
        {
            [button removeFromSuperview];
            bodyButtons = nil;
        }
    }
    if (legButtons)
    {
        for(UIButton *button in legButtons)
        {
            [button removeFromSuperview];
            legButtons = nil;
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self connectToHost];
    

    isPlayButton = YES;
    isPauseButton = NO;
    bodyNames= [NSArray arrayWithObjects:@"leftup1",@"leftup2",@"leftup3",@"lefthand",@"leftdown1",@"leftdown2",@"leftdown3",@"leftfoot",
                                         @"rightup1",@"rightup2",@"rightup3",@"righthand",@"rightdown1",@"rightdown2",@"rightdown3",@"rightfoot",
                                         @"middle1",@"middle2",@"middle3",@"middle4",nil];
    
    legNames = [NSArray arrayWithObjects:@"leftleg1",@"leftleg2",@"leftleg3",@"leftleg4",@"leftleg5",@"leftleg6",@"leftleg7", @"leftfoot",
                                        @"rightleg1",@"rightleg2",@"rightleg3",@"rightleg4",@"rightleg5",@"rightleg6",@"rightleg7", @"rightfoot",nil];
    
    bodyButtons = [[NSMutableArray alloc]initWithCapacity:20];
    legButtons = [[NSMutableArray alloc]initWithCapacity:20];
    
    self.treatInformation = [[TreatInformation alloc]init];
    self.runningInfomation = [[RunningInfomation alloc]init];
    
    if (self.picker == nil)
    {
        self.picker = [[UIImagePickerController alloc]init];
    }
    self.picker.delegate = self;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //添加扫动手势
    [self setupSwipe];
    
    
//    // 监测网络环境
//    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//    
//    /*
//     status
//     AFNetworkReachabilityStatusUnknown          = -1, 不知道监测的是什么
//     AFNetworkReachabilityStatusNotReachable     = 0,  没有检测到网络
//     AFNetworkReachabilityStatusReachableViaWWAN = 1,  蜂窝网
//     AFNetworkReachabilityStatusReachableViaWiFi = 2,  WIFI
//     */
//    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        NSLog(@"%zd",status);
//    }];
//    
//    [manager startMonitoring];
    


}
-(void)connectToHost
{
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (myDelegate.cclientSocket != nil)
    {
        self.clientSocket = myDelegate.cclientSocket;
        self.clientSocket.delegate = self;
        self.connected = myDelegate.cconnected;
    }
    //连接服务器
    if (!self.connected )
    {
        self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSLog(@"开始连接%@",self.clientSocket);
        NSError *error = nil;
        self.connected = [self.clientSocket connectToHost:myDelegate.host onPort:[myDelegate.port integerValue] viaInterface:nil withTimeout:-1 error:&error];
        if (self.connected)
        {
            NSLog(@"客户端尝试连接");
            [SVProgressHUD showWithStatus:@"正在连接设备"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL isWIFI = [self isWiFiEnabled];
                if (!isWIFI) {//如果WiFi没有打开，作出弹窗提示
                    [SVProgressHUD dismiss];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"无法连接设备"
                                                                                   message:@"Wi-Fi已关闭，请打开Wi-Fi以连接设备"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* settingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root"]options:@{} completionHandler:nil];
                    }];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:settingAction];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:^{
                    }];
                }
            });
        }
        else
        {
            self.connected = NO;
            NSLog(@"客户端未创建连接");
        }
    }
    else
    {
        NSLog(@"与服务器连接已建立 %@",self.clientSocket);
    }
}
#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //提示成功
    NSLog(@"连接成功");
    //获取连接的wifi名字
    id info = nil;
    NSString *wifiName;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs)
    {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        wifiName = info[@"SSID"];
    }
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"成功连接 %@",wifiName]];
    [SVProgressHUD dismissWithDelay:0.9];
    
    
    [self askForTreatInfomation];
    if ([self.view viewWithTag:disconnectViewtag])
    {
        [[self.view viewWithTag:disconnectViewtag]removeFromSuperview];
    }
    [self addTimer];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    
    //保存socket
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cclientSocket=self.clientSocket;
    myDelegate.cconnected = YES;
    myDelegate.wifiName = wifiName;
    self.connected = YES;
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{

    Byte *bytes = (Byte *)[data bytes];
    NSLog(@"%x",bytes[2]);
    //治疗信息
    if (bytes[2]==0x90)
    {
        [self.treatInformation analyzeWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureBodyView];
        });
    }
    //实时信息
    if (bytes[2]==0x91)
    {
        [self.runningInfomation analyzeWithData:data];
        [self askForTreatInfomation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureBodyView];
        });
    }
    //警告信息
    if (bytes[2]==0x95)
    {
        WarnMessage *warnMessage = [[WarnMessage alloc]init];
        NSString *message = [warnMessage analyzeWithData:data];
        [self showWarningMessage:message];
    }
    //治疗信息
    if(bytes[2]==0x98)
    {
        self.treatRecord = [[TreatRecord alloc]init];
        NSLog(@"------------------------------------------------");
        
        [self.treatRecord analyzeWithData:data];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        self.treatRecord.name = [userDefault objectForKey:@"name"];
        self.treatRecord.sex = [userDefault objectForKey:@"sex"];
        self.treatRecord.age = [userDefault objectForKey:@"age"];
        self.treatRecord.phoneNumber = [userDefault objectForKey:@"phoneNumber"];
        self.treatRecord.address = [userDefault objectForKey:@"address"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        [self takePhotoAlert];
        });
    }
    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1000)
    {
//        NSLog(@"发送成功");
    }
    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{

    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *wifiName = myDelegate.wifiName;
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (self.connected)
    {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"断开连接 %@",wifiName!=nil?wifiName:@"空气波"]];
        [SVProgressHUD dismissWithDelay:0.9];
    }else
    {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"无法连接设备，请检查您的网络设置"]];
        [SVProgressHUD dismissWithDelay:0.9];
    }
    
    NSLog(@"断开连接 error:%@",err);
    self.connected = NO;
    myDelegate.cconnected = NO;
    myDelegate.cclientSocket=nil;
    [self.connectTimer invalidate];
    self.connectTimer = nil;

}
#pragma mark - configureViews
-(void)configureView
{
    //tap样式
    CALayer *tapBorder = [CALayer layer];
    tapBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    tapBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:tapBorder];
    

    //配置开始按钮
    [self configurePlayButton];
    
    //配置进度条背景圈
    self.progressBackground.circleColor = UIColorFromHex(0x65BBA9);
    self.progressBackground.lineWith = 8.0;
    [self.progressBackground drawProgress:1];
    
    //进度圈
    self.progressView.circleColor = [UIColor whiteColor];
    self.progressView.lineWith = 9.0;
    self.progressView.label.text = [NSString stringWithFormat:@"100%%"];
    
    [self configureBodyView];
}
-(void)configureBodyView
{
    
    NSString *aport = self.treatInformation.aPort;
    //腿部八腔和六腔
    if ([aport isEqualToString:@"LEGA006"]||[aport isEqualToString:@"LEGA008"])
    {

        for (int i = 0; i<6; i++)
        {
            //设置腿部的背景块为背景色
            int legTags[] = {leftdown1tag,leftdown2tag,leftdown3tag,rightdown1tag,rightdown2tag,rightdown3tag};
            int legIndex[]={leftdown1index,leftdown2index,leftdown3index,rightdown1index,rightdown2index,rightdown3index};
            UIImageView *imgView = [self.backgroundView viewWithTag:legTags[i]];
            [imgView setImage:[UIImage imageNamed:bodyNames[legIndex[i]] withColor:@"white"]];
        }

        //去除其他按钮
        if ([bodyButtons count]>0)
        {
            for (int i = 0; i<[bodyButtons count]; i++)
            {
                [bodyButtons[i] removeFromSuperview];
            }
            bodyButtons = [[NSMutableArray alloc]initWithCapacity:20];
        }

        //没有加载过按钮则加载
        if ([legButtons count] == 0)
        {
            legButtons = [[NSMutableArray alloc]initWithCapacity:20];
            NSArray *lightUpLegsDics = @[@{@"position":@"leftleg1",   @"commit":[NSNumber numberWithUnsignedInteger:0xe4]},
                                         @{@"position":@"leftleg2",   @"commit":[NSNumber numberWithUnsignedInteger:0xe3]},
                                         @{@"position":@"leftleg3",   @"commit":[NSNumber numberWithUnsignedInteger:0xe2]},
                                         @{@"position":@"leftleg4",   @"commit":[NSNumber numberWithUnsignedInteger:0xe1]},
                                         @{@"position":@"leftleg5",   @"commit":[NSNumber numberWithUnsignedInteger:0xe0]},
                                         @{@"position":@"leftleg6",   @"commit":[NSNumber numberWithUnsignedInteger:0xcf]},
                                         @{@"position":@"leftleg7",   @"commit":[NSNumber numberWithUnsignedInteger:0xce]},
                                         @{@"position":@"leftfoot",   @"commit":[NSNumber numberWithUnsignedInteger:0x21]}];
            for (int i = 0; i<[legNames count]; i++)
            {
                int tag = legTags[i];
                //设置背景块颜色
                UIImageView *imgView = [self.backgroundView viewWithTag:tag];
                [imgView setImage:[UIImage imageNamed:legNames[i] withColor:@"grey"]];

                BodyButton *button = [self bodyButtonReturnWithTag:tag];
                button.enabled = NO;
                [button setImage:[UIImage imageNamed:legNames[i] withColor:@"grey"] forState:UIControlStateNormal];
                if (tag == rightfoottag)
                {
                    button.multiParamDic = [@{@"position":@"rightfoot", @"commit":[NSNumber numberWithUnsignedInteger:0x25]} copy];
                }
                //左腿八腔附带点亮模块的命令参数
                if (i<8)
                {
                    button.multiParamDic = [NSMutableDictionary dictionaryWithDictionary:lightUpLegsDics[i]];
                }
                [legButtons addObject:button];
                [self.backgroundView addSubview:button];
            }
        }
        //改变前先让所以按钮变成灰色/取消定时器
        if (self.treatInformation.treatState == Stop)
        {
            for (int i=0; i<[legNames count]; i++)
            {
                BodyButton *button = legButtons[i];
                [button setImage:[UIImage imageNamed:legNames[i] withColor:@"grey"]
                        forState:UIControlStateNormal];
                if (button.changeColorTimer != nil)
                {
                    [self deallocTimerWithButton:button];
                }
            }
        }
    }
    else if (aport !=nil)
    {
        
        for (int i = 0; i<[legNames count]; i++)
        {
            int tag = legTags[i];
            //设置腿部七块背景块颜色
            if (tag !=leftfoottag || tag != rightfoottag)
            {
                UIImageView *imgView = [self.backgroundView viewWithTag:tag];
                [imgView setImage:nil];
            }
        }
        
        //去除腿部八腔按钮
        if ([legButtons count] >0)
        {
//            for (int i = 0; i<[legButtons count]; i++)
//            {
//                BodyButton *button = legButtons[i];
//
//                [legButtons[i] removeFromSuperview];
//            }
            for (BodyButton *button in legButtons)
            {
                NSString *positionName = [button.multiParamDic objectForKey:@"positon"];
                if (!([positionName isEqualToString: @"leftfoot"]||[positionName isEqualToString:@"rightfoot"]))
                {
                    [button removeFromSuperview];
                }
                
            }
             legButtons = [[NSMutableArray alloc]initWithCapacity:20];
        }
        
        //没加载过身体部位则加载
        if ([bodyButtons count] == 0)
        {
            bodyButtons = [[NSMutableArray alloc]initWithCapacity:20];
            NSArray *lightUpCommitDics = @[@{@"position":@"leftup1",   @"commit":[NSNumber numberWithUnsignedInteger:0x18]},
                                           @{@"position":@"leftup2",   @"commit":[NSNumber numberWithUnsignedInteger:0x17]},
                                           @{@"position":@"leftup3",   @"commit":[NSNumber numberWithUnsignedInteger:0x16]},
                                           @{@"position":@"lefthand",  @"commit":[NSNumber numberWithUnsignedInteger:0x15]},
                                           @{@"position":@"leftdown1", @"commit":[NSNumber numberWithUnsignedInteger:0x1e]},
                                           @{@"position":@"leftdown2", @"commit":[NSNumber numberWithUnsignedInteger:0x1f]},
                                           @{@"position":@"leftdown3", @"commit":[NSNumber numberWithUnsignedInteger:0x20]},
                                           @{@"position":@"leftfoot",  @"commit":[NSNumber numberWithUnsignedInteger:0x21]},
                                           @{@"position":@"rightup1",  @"commit":[NSNumber numberWithUnsignedInteger:0x19]},
                                           @{@"position":@"rightup2",  @"commit":[NSNumber numberWithUnsignedInteger:0x1a]},
                                           @{@"position":@"rightup3",  @"commit":[NSNumber numberWithUnsignedInteger:0x1b]},
                                           @{@"position":@"righthand", @"commit":[NSNumber numberWithUnsignedInteger:0x1c]},
                                           @{@"position":@"rightdown1",@"commit":[NSNumber numberWithUnsignedInteger:0x22]},
                                           @{@"position":@"rightdown2",@"commit":[NSNumber numberWithUnsignedInteger:0x23]},
                                           @{@"position":@"rightdown3",@"commit":[NSNumber numberWithUnsignedInteger:0x24]},
                                           @{@"position":@"rightfoot", @"commit":[NSNumber numberWithUnsignedInteger:0x25]},
                                           @{@"position":@"middle1",   @"commit":[NSNumber numberWithUnsignedInteger:0x28]},
                                           @{@"position":@"middle2",   @"commit":[NSNumber numberWithUnsignedInteger:0x27]},
                                           @{@"position":@"middle3",   @"commit":[NSNumber numberWithUnsignedInteger:0x26]},
                                           @{@"position":@"middle4",   @"commit":[NSNumber numberWithUnsignedInteger:0x1d]}];
            //加载身体部位按钮
            for (int i=0; i<[bodyNames count]; i++)
            {
                int tag = bodyPartTags[i];
                //加载背景颜色块 否则button unable颜色变浅
                UIImageView *imgView = [self.backgroundView viewWithTag:tag];
                [imgView setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"]];

                BodyButton *button = [self bodyButtonReturnWithTag:tag];
                button.enabled = NO;
                [button setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"] forState:UIControlStateNormal];
                //button附带点亮模块的命令参数
                button.multiParamDic = [NSMutableDictionary dictionaryWithDictionary:lightUpCommitDics[i]];
                //加入bodybuttons数组
                [bodyButtons addObject:button];
                [self.backgroundView addSubview:button];
            }
        }
        //改变前先让所以按钮变成灰色/取消定时器
        if (self.treatInformation.treatState == Stop)
        {
            for (int i=0; i<[bodyNames count]; i++)
            {
                BodyButton *button = bodyButtons[i];
                [button setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"] forState:UIControlStateNormal];
                if (button.changeColorTimer != nil)
                {
                    [self deallocTimerWithButton:button];
                }
            }
        }
    }


    //停止更新压力和进度圈UI
    if (self.treatInformation.treatTime -1 == self.runningInfomation.treatProcessTime || self.treatInformation.treatState == Stop)
    {
        isPlayButton = YES;
        isPauseButton = NO;
        [self configurePlayButton];
        self.pressLabel.text = [NSString stringWithFormat:@"0"];
//        [self.progressView drawProgress:1];
        [self.progressBackground drawProgress:1];
        [self.progressView drawProgress:0];
        self.progressView.label.text = [NSString stringWithFormat:@"100%%"];
    }
    else if((self.treatInformation.treatState == Running && self.treatInformation.aPort != nil) ||self.treatInformation.treatState == Pause)
    {
        //treatInfomation.aPort != nil 确保收到了下位机的treatInfomation（运行）
        if (self.treatInformation.treatState == Running && self.treatInformation.aPort !=nil )
        {
            isPlayButton = NO;
            isPauseButton = YES;
            [self configurePlayButton];
        }
        //（暂停）
        else if(self.treatInformation.treatState == Pause)
        {
            isPlayButton = YES;
            isPauseButton = NO;
            [self configurePlayButton];
        }
        //显示压力圈
        CGFloat currentProgress =(CGFloat)(self.runningInfomation.treatProcessTime)/(CGFloat)self.treatInformation.treatTime;
        
        int progress = self.runningInfomation.treatProcessTime *100 / self.treatInformation.treatTime;
//      self.progressView.label.text = [NSString stringWithFormat:@"%d%%",100-(int)progress];
        self.progressView.label.text = [NSString stringWithFormat:@"%d%%",99-(int)progress];
        [self.progressView drawProgress:currentProgress];
        NSString *press = self.runningInfomation.press[self.runningInfomation.curFocuse];
        self.pressLabel.text = [NSString stringWithFormat:@"%@",press];
    }

    
    //A端


    if ([aport isEqualToString:@"ARMA003"])      {   [self configureLeftWithType:@"ARMA003"];   }
    else if ([aport isEqualToString:@"LEGA003"]) {   [self configureLeftWithType:@"LEGA003"];   }
    else if ([aport isEqualToString:@"ARMB004"])
    {
        [self configureLeftWithType:@"LEFTHAND"];
        [self configureLeftWithType:@"ARMA003"];
    }
    else if ([aport isEqualToString:@"LEGA004"])
    {
        [self configureLeftWithType:@"LEFTFOOT"];
        [self configureLeftWithType:@"LEGA003"];
    }
    else if ([aport isEqualToString:@"HNDA001"]||[aport isEqualToString:@"HANA008"])
    {
        [self configureLeftWithType:@"LEFTHAND"];
    }
    else if ([aport isEqualToString:@"FOTA001"]) {   [self configureLeftWithType:@"LEFTFOOT"];   }
    else if ([aport isEqualToString:@"ABDA004"]) {   [self configureLeftWithType:@"ABDA004"];    }
    else if ([aport isEqualToString:@"LEGA006"]) {   [self configureLeftWithType:@"LEGA006"];    }
    else if ([aport isEqualToString:@"LEGA008"]) {   [self configureLeftWithType:@"LEGA008"];    }
    
    
    //B端
    NSString *bport = self.treatInformation.bPort;
    if ([bport isEqualToString:@"ARMB003"]) {   [self configureRightWithType:@"ARMB003"];   }
    else if ([bport isEqualToString:@"LEGB003"]) {   [self configureRightWithType:@"LEGB003"];   }
    else if ([bport isEqualToString:@"ARMB004"])
    {
        [self configureRightWithType:@"RIGHTHAND"];
        [self configureRightWithType:@"ARMB003"];
    }
    else if ([bport isEqualToString:@"LEGB004"])
    {
        [self configureRightWithType:@"RIGHTFOOT"];
        [self configureRightWithType:@"LEGB003"];
    }
    else if ([bport isEqualToString:@"HNDB001"]||[bport isEqualToString:@"HANB008"])
    {
        [self configureRightWithType:@"RIGHTHAND"];
    }
    else if ([bport isEqualToString:@"FOTB001"]) {   [self configureRightWithType:@"RIGHTFOOT"];   }
    else if ([bport isEqualToString:@"ABDB004"]) {   [self configureRightWithType:@"ABDB004"];    }
}

-(void)configureLeftWithType:(NSString *)type
{
    //手臂三腔 腿部梯度
    if ([type isEqualToString:@"ARMA003"]||[type isEqualToString:@"LEGA003"])
    {   int indexArray[3];
        if ([type isEqualToString:@"ARMA003"]){     indexArray[0]= leftup3index;  indexArray[1]=leftup2index;  indexArray[2]=leftup1index;      }else
        if ([type isEqualToString:@"LEGA003"]){     indexArray[0]= leftdown3index;indexArray[1]=leftdown2index;indexArray[2]=leftdown1index;    }
        int startIndex = indexArray[2];
        for (int i = startIndex; i<startIndex+3; i++)
        {
            [self enableButton:bodyButtons[i]];
        }
        for (int i = 0; i<3; i++)
        {
            //判断单腔是否使能
            int index = indexArray[i];
            BodyButton *button = bodyButtons[index];
            if ([self.treatInformation.enabled[i+1] isEqualToString:@"1" ])
            {
                if (self.treatInformation.treatState == Running)
                {
                    NSInteger cellState = [self.runningInfomation.cellState[i+1] integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil)
                            {
                                [self startTimerToChangeColorOfButton:bodyButtons[index]];
                            }
                            break;
                        case KeepingAir:
                            if(button.changeColorTimer != nil)
                            {
                                [self deallocTimerWithButton:button];
                            }
                            [bodyButtons[index]setImage:[UIImage imageNamed:bodyNames[index] withColor:@"green"]forState:UIControlStateNormal];
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                     [self deallocTimerWithButton:button];
                     [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                }
            }
            else
            {
                [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"grey"] forState:UIControlStateNormal];
            }
        }
    }
    //手部一腔
    else if ([type isEqualToString:@"LEFTHAND"])
    {
        BodyButton *button = bodyButtons[lefthandindex];
        [self enableButton:button];
        if ([self.treatInformation.enabled[0] isEqualToString:@"1"])
        {
            if (self.treatInformation.treatState == Running)
            {
                NSInteger cellState = [self.runningInfomation.cellState[0] integerValue];
                switch (cellState)
                {
                    case UnWorking:
                        [bodyButtons[lefthandindex] setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
                        break;
                    case Working:
                        if (button.changeColorTimer == nil)
                        {
                            [self startTimerToChangeColorOfButton:bodyButtons[lefthandindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil)
                        {
                            [self deallocTimerWithButton:button];
                        }
                        [bodyButtons[lefthandindex]setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"green"]forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
            else
            {
                [self deallocTimerWithButton:button];
                [bodyButtons[lefthandindex ] setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [button setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"grey"] forState:UIControlStateNormal];
        }
    }
    //足部一腔
    else if ([type isEqualToString:@"LEFTFOOT"])
    {
        BodyButton *button = bodyButtons[leftfootindex];
        [self enableButton:button];
        if ([self.treatInformation.enabled[0] isEqualToString:@"1"])
        {
 
            if (self.treatInformation.treatState == Running)
            {
                NSInteger cellState = [self.runningInfomation.cellState[0] integerValue];
                switch (cellState)
                {
                    case UnWorking:
                        [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"yellow"] forState:UIControlStateNormal];
                        break;
                    case Working:
                        if (button.changeColorTimer == nil)
                        {
                            [self startTimerToChangeColorOfButton:bodyButtons[leftfootindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil) {
                            [self deallocTimerWithButton:button];
                        }
                        [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"green"]forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
            else
            {
                [self deallocTimerWithButton:button];
                [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"yellow"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"grey"] forState:UIControlStateNormal];
        }
        
    }
    //腹部
    else if ([type isEqualToString:@"ABDA004"])
    {
        int indexArray[]={middle4index,middle3index,middle2index,middle1index};
        
        for (int i = middle1index; i<middle1index+4; i++)
        {
            [self enableButton:bodyButtons[i]];
        }
        for (int i = 0; i<4; i++)
        {
            int index = indexArray[i];
            BodyButton *button = bodyButtons[index];

            if ([self.treatInformation.enabled[i] isEqualToString:@"1" ])
            {
                if (self.treatInformation.treatState == Running)
                {
                    NSInteger cellState = [self.runningInfomation.cellState[i]integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil)
                            {
                                [self startTimerToChangeColorOfButton:button];
                            }
                            break;
                        case KeepingAir:
                            if (button.changeColorTimer !=nil)
                            {
                                [self deallocTimerWithButton:button];
                            }
                            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"green"] forState:UIControlStateNormal];
                            break;
                        default:
                            break;

                    }
                }
                else
                {
                    [self deallocTimerWithButton:button];
                    [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                }

            }
            else
            {
                [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"grey"] forState:UIControlStateNormal];
            }
        }
    }
    //左腿八腔
    else if ([type isEqualToString:@"LEGA006"]||[type isEqualToString:@"LEGA008"])
    {
        int startIndex;
        if ([type isEqualToString:@"LEGA006"])
        {
            startIndex =leftleg3index;
            for (int i = startIndex; i<startIndex+6; i++)
            {
                [self enableButton:legButtons[i]];
            }
        }
        else
        {
            startIndex = leftleg1index;
            for (int i = startIndex;i<startIndex+8; i++)
            {
                [self enableButton:legButtons[i]];
            }
        }
        
        for (int i = startIndex; i<8; i++)
        {
            BodyButton *button = legButtons[i];
            if ([self.treatInformation.enabled[7-i]isEqualToString:@"1"])
            {
                if(self.treatInformation.treatState == Running)
                {
                    NSInteger cellState = [self.runningInfomation.cellState[7-i] integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [legButtons[i] setImage:[UIImage imageNamed:legNames[i] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil)
                            {
                                [self startTimerToChangeColorOfButton:button];
                            }
                            break;
                        case KeepingAir:
                            if (button.changeColorTimer !=nil)
                            {
                                [self deallocTimerWithButton:button];
                            }
                            [legButtons[i] setImage:[UIImage imageNamed:legNames[i] withColor:@"green"] forState:UIControlStateNormal];
                            break;
                        default:
                            break;
                    }
                }
                else //非运行状态
                {
                    if (button.changeColorTimer !=nil)
                    {
                        [self deallocTimerWithButton:button];
                    }
                    [button setImage:[UIImage imageNamed:legNames[i] withColor:@"yellow"] forState:UIControlStateNormal];
                }

            }
            else
            {
                [button setImage:[UIImage imageNamed:legNames[i]withColor:@"grey"] forState:UIControlStateNormal];
            }
        }
    }
}
-(void)startTimerToChangeColorOfButton:(BodyButton*)button
{
    button.changeColorTimer =[NSTimer timerWithTimeInterval:0.5
                                                     target:button
                                                   selector:@selector(changeGreenColor)
                                                   userInfo:nil
                                                    repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:button.changeColorTimer forMode:NSDefaultRunLoopMode];
}
-(void)deallocTimerWithButton:(BodyButton *)button
{
    [button.changeColorTimer invalidate];
    button.changeColorTimer = nil;
}

-(void)configureRightWithType:(NSString *)type
{
    //手臂三腔 腿部梯度
    if ([type isEqualToString:@"ARMB003"]||[type isEqualToString:@"LEGB003"])
    {   int indexArray[3];
        if ([type isEqualToString:@"ARMB003"]){     indexArray[0]= rightup3index;  indexArray[1]=rightup2index;  indexArray[2]=rightup1index;      }
                                          else{     indexArray[0]= rightdown3index;indexArray[1]=rightdown2index;indexArray[2]=rightdown1index;    }
        int startIndex = indexArray[2];
        for (int i = startIndex; i<startIndex+3; i++){     [self enableButton:bodyButtons[i]];     }
        for (int i = 0; i<3; i++)
        {
            int index = indexArray[i];
            BodyButton *button = bodyButtons[index];
            if ([self.treatInformation.enabled[i+5] isEqualToString:@"1" ])
            {
                int index = indexArray[i];
                //                NSLog(@"treat state =%d",treatInfomation.treatState);
                if (self.treatInformation.treatState == Running)
                {
                    
                    NSInteger cellState = [self.runningInfomation.cellState[i+5] integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil)
                            {
                                [self startTimerToChangeColorOfButton:bodyButtons[index]];
                            }
                            
                            break;
                        case KeepingAir:
                            if(button.changeColorTimer != nil)
                            {
                                [self deallocTimerWithButton:button];
                            }
                            [bodyButtons[index]setImage:[UIImage imageNamed:bodyNames[index] withColor:@"green"]forState:UIControlStateNormal];
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    [self deallocTimerWithButton:button];
                    [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                }
            }
            else
            {
                [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"grey"] forState:UIControlStateNormal];
            }
        }
    }
    //手部一腔
    else if ([type isEqualToString:@"RIGHTHAND"])
    {
        BodyButton *button = bodyButtons[righthandindex];
        [self enableButton:button];
        if ([self.treatInformation.enabled[4] isEqualToString:@"1"])
        {
        
            if (self.treatInformation.treatState == Running)
            {
                NSInteger cellState = [self.runningInfomation.cellState[4] integerValue];
                switch (cellState)
                {
                    case UnWorking:
                        [bodyButtons[righthandindex] setImage:[UIImage imageNamed:bodyNames[righthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
                        break;
                    case Working:
                        if (button.changeColorTimer == nil) {
                            [self startTimerToChangeColorOfButton:bodyButtons[righthandindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil) {
                            [self deallocTimerWithButton:button];
                        }
                        [bodyButtons[righthandindex]setImage:[UIImage imageNamed:bodyNames[righthandindex] withColor:@"green"]forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
            else
            {
                [self deallocTimerWithButton:button];
                [bodyButtons[righthandindex ] setImage:[UIImage imageNamed:bodyNames[righthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [button setImage:[UIImage imageNamed:bodyNames[righthandindex] withColor:@"grey"] forState:UIControlStateNormal];
        }
        
    }
    //足部一腔
    else if ([type isEqualToString:@"RIGHTFOOT"])
    {
        BodyButton *button = bodyButtons[rightfootindex];
        [self enableButton:button];
        if ([self.treatInformation.enabled[4] isEqualToString:@"1"])
        {
            
            if (self.treatInformation.treatState == Running)
            {
                NSInteger cellState = [self.runningInfomation.cellState[4] integerValue];
                switch (cellState)
                {
                    case UnWorking:
                        [button setImage:[UIImage imageNamed:bodyNames[rightfootindex] withColor:@"yellow"] forState:UIControlStateNormal];
                        break;
                    case Working:
                        if (button.changeColorTimer == nil)
                        {
                            [self startTimerToChangeColorOfButton:bodyButtons[rightfootindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil)
                        {
                            [self deallocTimerWithButton:button];
                        }
                        [button setImage:[UIImage imageNamed:bodyNames[rightfootindex] withColor:@"green"]forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }

            }
            else
            {
                [self deallocTimerWithButton:button];
                [button setImage:[UIImage imageNamed:bodyNames[rightfootindex] withColor:@"yellow"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [button setImage:[UIImage imageNamed:bodyNames[rightfootindex] withColor:@"grey"] forState:UIControlStateNormal];
        }
    }
    //腹部
    else
    {
        int indexArray[]={middle4index,middle3index,middle2index,middle1index};
        for (int i = middle1index; i<middle1index+4; i++)
        {
            [self enableButton:bodyButtons[i]];
        }
        for (int i = 0; i<4; i++)
        {
            int index = indexArray[i];
            BodyButton *button = bodyButtons[index];
            if ([self.treatInformation.enabled[i+4] isEqualToString:@"1" ])
            {
                if (self.treatInformation.treatState == Running)
                {
                    NSInteger cellState = [self.runningInfomation.cellState[i+4]integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil) {
                                [self startTimerToChangeColorOfButton:button];}
                                break;
                        case KeepingAir:
                            if (button.changeColorTimer !=nil) {
                                [self deallocTimerWithButton:button];
                                }
                            [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"green"] forState:UIControlStateNormal];
                                
                                break;
                        default:
                            break;
                    }
                }
                //不是运行状态
                else
                {
                    [self deallocTimerWithButton:button];
                    [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                }

            }
            else
            {
                [button setImage:[UIImage imageNamed:bodyNames[index] withColor:@"grey"] forState:UIControlStateNormal];
            }
        }
    }
}
-(BodyButton *)bodyButtonReturnWithTag:(NSInteger)tag
{
    BodyButton *button = [[BodyButton alloc]init];
    //取背景块的frame
    button.frame = [self.backgroundView viewWithTag:tag].frame;
    switch (tag)
    {
        case middle1tag:
        case middle2tag:
        case middle3tag:
        case middle4tag: [[button imageView]setContentMode:UIViewContentModeScaleToFill];
            break;
        default: [[button imageView]setContentMode:UIViewContentModeScaleAspectFit];
            break;
    }
    return button;
}
-(void)enableButton:(BodyButton *)button
{
    button.enabled = YES;
    [button addTarget:self action:@selector(lightupBodyButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)configurePlayButton
{
    if (isPlayButton == YES)
    {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"stop_green"] forState:UIControlStateNormal];
    }
    
    if (isPauseButton)
    {
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_green"] forState:UIControlStateNormal];
        self.pauseButton.enabled = YES;
    }
    else
    {
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_write"] forState:UIControlStateNormal];
        self.pauseButton.enabled = NO;
    }
}
-(void)showWarningMessage:(NSString *)message
{
//    UILabel *warningLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 520, 135, 35)];
    UILabel *warningLabel = [[UILabel alloc]init];
    warningLabel.textAlignment = NSTextAlignmentLeft;
    warningLabel.text = message;
    warningLabel.textColor = UIColorFromHex(0xFF8247);
//    UIImageView *warningImageView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 520, 35, 35)];
    UIImageView *warningImageView = [[UIImageView alloc]init];
    warningImageView.image = [UIImage imageNamed:@"warning"];
    [[self.view viewWithTag:1000] addSubview:warningImageView];
    [[self.view viewWithTag:1000] addSubview:warningLabel];
    
    //添加约束
    
    //width约束
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:135];
    //height约束
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:35];
    [warningLabel addConstraints:@[widthConstraint,heightConstraint]];
    
    //添加centerX约束
    NSLayoutConstraint *centerXConstraint =[NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    //添加button约束
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.backgroundView addConstraints:@[centerXConstraint,bottomConstraint]];
    
    
    
    
    
    [warningImageView.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    [warningLabel.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    // 延迟的时间
    int64_t delayInSeconds = 4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [warningLabel removeFromSuperview];
        [warningImageView removeFromSuperview];
    });
}
#pragma mark - commit
- (void)start
{
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:0x10]] withTimeout:-1 tag:0];
}
-(void)pause
{
    
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:0x11]] withTimeout:-1 tag:0];
    
}
-(void)askForTreatInfomation
{
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:0x0162]] withTimeout:-1 tag:1000];
}
-(void)lightupBodyButton:(BodyButton *)button
{
    [button changeGreyColor];
    NSNumber *commitNumber = [button.multiParamDic objectForKey:@"commit"];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:[commitNumber unsignedIntegerValue]]] withTimeout:-1 tag:0];
}
//添加计时器
-(void)addTimer
{
    //长连接定时器
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:8.0
                                                         target:self
                                                       selector:@selector(longConnectToSocket)
                                                       userInfo:nil
                                                        repeats:YES];
    //将定时器添加到当前运行循环，并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    [self.clientSocket writeData:[Pack packetWithCmdid:0x93 addressEnabled:NO addr:nil
                                                               dataEnabled:NO data:nil] withTimeout:- 1 tag:2];
}
#pragma mark - Take Photo

-(void)takePhotoAlert
{
    NSString *title = @"是否拍照记录治疗情况？";
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    //修改提示标题的颜色和大小
    NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
    [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
    [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
    [alert setValue:titleAtt forKey:@"attributedTitle"];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                 [self saveRecord];
                                                             });
                                                         }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action){
                                                              [self takePhoto];
                                                          }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)takePhoto
{
    [self presentViewController:self.picker animated:YES completion:NULL];
};
//选择照片完成后回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //开一个线程保存
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //保存图片
        self.treatRecord.hasImage = YES;
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self saveImage:image];
        //保存记录
        [self saveRecord];
        
        //保存到本地相册
        if (self.picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        }
        //保存完将图片消除
        self.treatRecord.imagePath = nil;
    });
    [self.picker dismissViewControllerAnimated:YES completion:^{
             [self configureBodyView];
        }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
       [self saveRecord];
    });
    [self.picker dismissViewControllerAnimated:YES completion:NULL];
}

//保存
-(void)saveRecord
{
        //文件名
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        if (!documents)
        {
            NSLog(@"目录未找到");
        }
        NSString *documentPath = [documents stringByAppendingPathComponent:@"record.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:documentPath])
        {
            [fileManager createFileAtPath:documentPath contents:nil attributes:nil];
        }
        NSArray *recordArray = [[NSArray alloc]init];
        //取出以前保存的record数组
        if ([fileManager fileExistsAtPath:documentPath])
        {
            NSData * resultdata = [[NSData alloc] initWithContentsOfFile:documentPath];
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:resultdata];
            recordArray = [unArchiver decodeObjectForKey:@"recordArray"];
        }
        NSMutableArray *array = [NSMutableArray arrayWithArray:recordArray];
        //新增record
        [array addObject:self.treatRecord];
        recordArray = [array copy];
        //写入文件
        NSMutableData *data = [[NSMutableData alloc] init] ;
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data] ;
        [archiver encodeObject:recordArray forKey:@"recordArray"];
        [archiver finishEncoding];
        
        BOOL success = [data writeToFile:documentPath atomically:YES];
        if (!success)
        {
            NSLog(@"写入文件失败");
        }
}
-(void)saveImage:(UIImage *)image
{
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.treatRecord.idString]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imagePath])
    {
        [fileManager createFileAtPath:imagePath contents:nil attributes:nil];
    }
    self.treatRecord.imagePath = imagePath;
    BOOL success = [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            [SVProgressHUD dismissWithDelay:0.9];
        });

    }
}
#pragma mark - Private Method
- (NSString *)getCurrentTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime = [date timeIntervalSince1970];
    NSString *currentTimeStr = [NSString stringWithFormat:@"%.0f", currentTime];
    return currentTimeStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)returnHome:(id)sender
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.clientSocket disconnect];
}

- (IBAction)tapPlayButton:(id)sender
{
    [self start];
}

- (IBAction)tapPauseButton:(id)sender
{

    [self pause];
}

- (IBAction)tapSettingButton:(id)sender
{
    NSInteger treatWay = self.treatInformation.treatWay;
    switch (treatWay)
    {
        case Standart:
            [self performSegueWithIdentifier:@"MainToStandard" sender:nil];
            break;
        case Gradient :
            [self performSegueWithIdentifier:@"MainToGradient" sender:nil];
            break;
        case Parameter:
            [self performSegueWithIdentifier:@"MainToParameter" sender:nil];
            break;
        case Solution:
            [self performSegueWithIdentifier:@"MainToSolution" sender:nil];
            break;
        default:
            [self performSegueWithIdentifier:@"MainToStandard" sender:nil];
            break;
    }
}

- (void)reconnect:(id)sender
{
    NSError *error= nil;
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    AppDelegate *myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.clientSocket connectToHost:myDelegate.host onPort:[myDelegate.port integerValue] viaInterface:nil withTimeout:-1 error:&error];

}
-(CABasicAnimation *)warningMessageAnimation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 8.0f;
    animation.removedOnCompletion = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    return animation;
}
-(NSData*) dataWithValue:(NSInteger)value
{
    //大端模式
    Byte src[2]={0,0};
    src[0] =  (Byte) ((value>>8) & 0xFF);
    src[1] =  (Byte) (value & 0xFF);
    NSData *data = [NSData dataWithBytes:src length:2];
    return data;
}

-(NSData*) dataWithBytes:(Byte[])bytes
{
    NSData *data = [NSData dataWithBytes:bytes length:2];
    return data;
}
//修改图片大小
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [reSizeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
- (BOOL) isWiFiEnabled
{
    NSCountedSet * cset = [[NSCountedSet alloc] init];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

#pragma mark - <轻扫手势>
- (void)setupSwipe
{
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    [self.view addGestureRecognizer:swipe];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;

}
- (void)swipeRight
{
//    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]animated:YES];
    [self.clientSocket disconnect];
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MainToStandard"])
    {
        StandardTreatViewController *controller = (StandardTreatViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInformation;
    }
    else if([segue.identifier isEqualToString:@"MainToGradient"])
    {
        GradientTreatViewController *controller = (GradientTreatViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInformation;
    }
    else if([segue.identifier isEqualToString:@"MainToParameter"])
    {
        ParameterTreatViewController  *controller = (ParameterTreatViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInformation;
    }else if([segue.identifier isEqualToString:@"MainToSolution"])
    {
        SolutionTreatViewController *controller = (SolutionTreatViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInformation;
    }else if ([segue.identifier isEqualToString:@"MainToSetting"])
    {
        SettingViewController *controller = (SettingViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInformation;
        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                                   dataEnabled:YES data:[self dataWithValue:0xaf]] withTimeout:-1 tag:0];
    }
}
@end
