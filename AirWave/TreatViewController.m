 //
//  TreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import <GCDAsyncSocket.h>

#import "Pack.h"
#import "BodyButton.h"
#import "TreatViewController.h"

#import "TreatInformation.h"
#import "RunningInfomation.h"
#import "UIImage+ImageWithColor.h"
#import "ProgressView.h"
#import "WarnMessage.h"
#import "AppDelegate.h"
#import "StandardTreatViewController.h"
#import "GradientTreatViewController.h"
#import "ParameterTreatViewController.h"
#import "SolutionTreatViewController.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]

typedef NS_ENUM(NSUInteger,BodyButtonIndexs)
{
    leftup1index,leftup2index,leftup3index,lefthandindex,leftdown1index,leftdown2index,leftdown3index,leftfootindex,
    rightup1index,rightup2index,rightup3index,righthandindex,rightdown1index,rightdown2index,rightdown3index,rightfootindex,
    middle1index,middle2index,middle3index,middle4index
};
typedef NS_ENUM(NSUInteger,LegButtonIndexs)
{
    leftleg1index,leftleg2index,leftleg3index,leftleg4index,leftleg5index,leftleg6index,leftleg7index
};
typedef NS_ENUM(NSUInteger,TreatState)
{   Running,Stop,Pause,Unconnecte   };
typedef NS_ENUM(NSUInteger,CellState)
{
    UnWorking,Working,KeepingAir
};
typedef NS_ENUM(NSUInteger,TreatWay)
{
    Standart = 1,Gradient,Parameter,Solution
};
typedef NS_ENUM(NSUInteger,BodyTags)
{
    leftup1tag   =17,leftup2tag   =16,leftup3tag   =15,lefthandtag  =14,leftdown1tag =13,leftdown2tag =12,leftdown3tag =11,
    leftfoottag  =10,rightup1tag  =27,rightup2tag  =26,rightup3tag  =25,righthandtag =24,rightdown1tag=23,rightdown2tag=22,
    rightdown3tag=21,rightfoottag =20,middle1tag   =33,middle2tag   =32,middle3tag   =31,middle4tag   =30,
    
    rightleg1tag =47,rightleg2tag =46,rightleg3tag =45,rightleg4tag =44,rightleg5tag =43,rightleg6tag =42,rightleg7tag =41,
    leftleg1tag  =57,leftleg2tag  =56,leftleg3tag  =55,leftleg4tag  =54,leftleg5tag  =53,leftleg6tag  =52,leftleg7tag  =51
    
};
static int bodyPartTags[] = {leftup1tag,leftup2tag,leftup3tag,lefthandtag,leftdown1tag,leftdown2tag,leftdown3tag,leftfoottag,rightup1tag,rightup2tag,rightup3tag,righthandtag,rightdown1tag,rightdown2tag,rightdown3tag,rightfoottag,middle1tag,middle2tag,middle3tag,middle4tag};

static int legTags[] = {leftleg1tag,leftleg2tag,leftleg3tag,leftleg4tag,leftleg5tag,leftleg6tag,leftleg7tag,leftfoottag,rightleg1tag,rightleg2tag,rightleg3tag,rightleg4tag,rightleg5tag,rightleg6tag,rightleg7tag,rightfoottag};

NSString *const HOST = @"10.10.100.254";
NSString *const POST = @"8080";

@interface TreatViewController ()<GCDAsyncSocketDelegate>
//客户端socket
@property (strong,nonatomic)GCDAsyncSocket *clientSocket;
//计时器
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic,strong) NSTimer *changeColorTimer;
@property (nonatomic,strong) TreatInformation *treatInformation;
@property (nonatomic,strong) RunningInfomation *runningInfomation;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (weak, nonatomic) IBOutlet ProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *warnningLabel;



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
    [self askForTreatInfomation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
        self.connected = [self.clientSocket connectToHost:HOST onPort:[POST integerValue] viaInterface:nil withTimeout:-1 error:&error];
        if (self.connected)
        {
            NSLog(@"客户端尝试连接");
        }
        else
        {
            self.connected = NO;
            NSLog(@"客户端未创建连接");
        }
    }
    else
    {
        NSLog(@"与服务器连接已建立");
    }
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
//    [self askForTreatInfomation];
    [self configureView];
}

-(void)viewWillDisappear:(BOOL)animated{
    
//    for (int i=0; i<[bodyNames count]; i++)
//    {
//        [bodyButtons[i] removeFromSuperview];
//    }
}


#pragma mark - GCDAsyncSocketDelegate

/**
 连接主机对应端口号
 
 @param sock 客户端socket
 @param host 主机
 @param port 端口号
 
 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功");
    [self addTimer];
    // 连接后,可读取服务器端的数据
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    
    //保存socket
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cclientSocket=self.clientSocket;
    myDelegate.cconnected = YES;
    self.connected = YES;
    
}
/**
 读取数据
 
 @param sock 客户端的Socket
 @param data 读取到的数据
 @param tag 当前读取的标记
 */
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text;
    Byte *bytes = (Byte *)[data bytes];
    
    text = [NSString stringWithFormat:@"%d",bytes[2]];
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
    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接 error:%@",err);
    self.clientSocket = nil;
    
    
    self.connected = NO;
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cconnected = NO;
    

    NSError *error = nil;
    self.connected = [self.clientSocket connectToHost:HOST onPort:[POST integerValue] viaInterface:nil withTimeout:-1 error:&error];
    [self.connectTimer invalidate];
}
#pragma mark - configureViews
-(void)configureView
{
    //导航栏
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.barBtItem.tintColor = UIColorFromHex(0xFFFFFF);
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
    
    //配置播放按钮
    [self configurePlayButton];
    
    //配置进度条
    [self.progressView drawProgress:1];
    self.progressView.label.text = [NSString stringWithFormat:@"100%%"];

}
-(void)configureBodyView
{
    
    NSString *aport = self.treatInformation.aPort;
    
    

    //腿部八腔和六腔
    if ([aport isEqualToString:@"LEGA006"]||[aport isEqualToString:@"LEGA008"])
    {

        //去除其他按钮
        if ([bodyButtons count] >0)
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
            NSArray *lightUpLegsDics = @[@{@"position":@"leftleg1",   @"commit":[NSNumber numberWithUnsignedInteger:0xe4]},
                                         @{@"position":@"leftleg2",   @"commit":[NSNumber numberWithUnsignedInteger:0xe2]},
                                         @{@"position":@"leftleg3",   @"commit":[NSNumber numberWithUnsignedInteger:0xe0]},
                                         @{@"position":@"leftleg4",   @"commit":[NSNumber numberWithUnsignedInteger:0x21]},
                                         @{@"position":@"leftleg5",   @"commit":[NSNumber numberWithUnsignedInteger:0xe3]},
                                         @{@"position":@"leftleg6",   @"commit":[NSNumber numberWithUnsignedInteger:0xe1]},
                                         @{@"position":@"leftleg7",   @"commit":[NSNumber numberWithUnsignedInteger:0xcf]},
                                         @{@"position":@"leftfoot",   @"commit":[NSNumber numberWithUnsignedInteger:0xee]}];
            for (int i = 0; i<[legNames count]; i++)
            {
                int tag = legTags[i];
                BodyButton *button = [self bodyButtonReturnWithTag:tag];
                button.enabled = NO;
                [button setImage:[UIImage imageNamed:legNames[i] withColor:@"grey"] forState:UIControlStateNormal];
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
                [button setImage:[UIImage imageNamed:legNames[i] withColor:@"grey"] forState:UIControlStateNormal];
                button.enabled = NO;
                if (button.changeColorTimer != nil)
                {
                    [self deallocTimerWithButton:button];
                }
            }
        }
    }
    else
    {

        //去除腿部八腔按钮
        if ([legButtons count] >0)
        {
            for (int i = 0; i<[legButtons count]; i++)
            {
                [legButtons[i] removeFromSuperview];
            }
             legButtons = [[NSMutableArray alloc]initWithCapacity:20];
        }
        
        //没加载过身体部位则加载
        if ([bodyButtons count] == 0)
        {
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
                button.enabled = NO;
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
        [self.progressView drawProgress:1];
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
        
        self.progressView.label.text = [NSString stringWithFormat:@"%d%%",(int)progress];
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
                        if (button.changeColorTimer == nil) {
                            [self startTimerToChangeColorOfButton:bodyButtons[lefthandindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil) {
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
                [bodyButtons[leftfootindex] setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
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
                if(self.treatInformation.treatWay == Running)
                {
                    NSInteger cellState = [self.runningInfomation.cellState[7-i]integerValue];
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
                    [self deallocTimerWithButton:button];
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
                        if (button.changeColorTimer == nil) {
                            [self startTimerToChangeColorOfButton:bodyButtons[rightfootindex]];
                        }
                        break;
                    case KeepingAir:
                        if (button.changeColorTimer != nil) {
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
                [button setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
            }
        }
        else
        {
            [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"grey"] forState:UIControlStateNormal];
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
-(void)updateBodyButton
{
    [self askForTreatInfomation];
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
    UILabel *warningLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 520, 135, 35)];
    warningLabel.textAlignment = NSTextAlignmentLeft;
    warningLabel.text = message;
    warningLabel.textColor = UIColorFromHex(0xFF8247);
    UIImageView *warningImageView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 520, 35, 35)];
    warningImageView.image = [UIImage imageNamed:@"warning"];
    [[self.view viewWithTag:1000] addSubview:warningImageView];
    [[self.view viewWithTag:1000] addSubview:warningLabel];
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
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {0,0x10};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
}
-(void)pause
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {0,0x11};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
    
}
//-(void)continue
//{
//    Pack *pack = [[Pack alloc]init];
//    Byte addrBytes[2] = {0,0};
//    Byte dataBytes[2] = {0,0x12};
//    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
//                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
//    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
//}
-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {1,0x62};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:1000];
}
-(void)lightupBodyButton:(BodyButton *)button
{
    [button changeGreyColor];
    NSNumber *commitNumber = [button.multiParamDic objectForKey:@"commit"];
    Pack *pack = [[Pack alloc]init];
    Byte dataBytes[2] = {0,[commitNumber unsignedIntegerValue]};
    Byte addrBytes[2] = {0,0};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
    
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
    //[[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    Pack *pack =[[Pack alloc]init];
    NSData *sendData = [pack packetWithCmdid:0x93 addressEnabled:NO addr:nil dataEnabled:NO data:nil];
    [self.clientSocket writeData:sendData withTimeout:- 1 tag:2];
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
    switch (treatWay) {
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
#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self askForTreatInfomation];
    if ([segue.identifier isEqualToString:@"MainToStandard"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        StandardTreatViewController *controller = (StandardTreatViewController *)navigationController.topViewController;
        controller.treatInfomation = self.treatInformation;
    }
    else if([segue.identifier isEqualToString:@"MainToGradient"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        GradientTreatViewController *controller = (GradientTreatViewController *)navigationController.topViewController;
        controller.treatInfomation = self.treatInformation;
    }
    else if([segue.identifier isEqualToString:@"MainToParameter"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        ParameterTreatViewController  *controller = (ParameterTreatViewController *)navigationController.topViewController;
        controller.treatInfomation = self.treatInformation;
    }else if([segue.identifier isEqualToString:@"MainToSolution"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SolutionTreatViewController *controller = (SolutionTreatViewController *)navigationController.topViewController;
        controller.treatInfomation = self.treatInformation;
    }
}
@end
