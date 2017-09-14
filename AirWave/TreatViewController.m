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

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]

#define LEGA003 0
#define ARMA003 1
#define LEGA004 2
#define ARMB004 3
#define ABDA004 4
#define FOTA001 5
#define HNDA001 6
#define HANA008 7
#define NONA000 8  


#define LEGB003 9
#define ARMB003 10
#define LEGB004 11
//#define ARMB004 12
#define ABDB004 13
#define FOTB001 14
 #define HNDB001 15
#define HANB008 16
#define NONB000 17

#define LEGA006 18              
#define LEGA008 19



typedef NS_ENUM(NSUInteger,BodyButtonIndexs)
{
    leftup1index,leftup2index,leftup3index,lefthandindex,leftdown1index,leftdown2index,leftdown3index,leftfootindex,
    rightup1index,rightup2index,rightup3index,righthandindex,rightdown1index,rightdown2index,rightdown3index,rightfootindex,
    middle1index,middle2index,middle3index,middle4index
};
typedef NS_ENUM(NSUInteger,TreatState)
{   Running,Stop,Pause,Unconnecte   };
typedef NS_ENUM(NSUInteger,CellState)
{
    UnWorking,Working,KeepingAir
};
typedef NS_ENUM(NSUInteger,BodyTags)
{
    leftup1tag   =17,leftup2tag   =16,leftup3tag   =15,lefthandtag  =14,leftdown1tag =13,leftdown2tag =12,leftdown3tag =11,
    leftfoottag  =10,rightup1tag  =27,rightup2tag  =26,rightup3tag  =25,righthandtag =24,rightdown1tag=23,rightdown2tag=22,
    rightdown3tag=21,rightfoottag =20,middle1tag   =33,middle2tag   =32,middle3tag   =31,middle4tag   =30
};
static int bodyPartTags[] = {leftup1tag,leftup2tag,leftup3tag,lefthandtag,leftdown1tag,leftdown2tag,leftdown3tag,leftfoottag,rightup1tag,rightup2tag,rightup3tag,righthandtag,rightdown1tag,rightdown2tag,rightdown3tag,rightfoottag,middle1tag,middle2tag,middle3tag,middle4tag};

NSString *const ARMB00 = @"ARMB004";
NSString *const HOST = @"10.10.100.254";
NSString *const POST = @"8080";

@interface TreatViewController ()<GCDAsyncSocketDelegate>
//客户端socket
@property (strong,nonatomic)GCDAsyncSocket *clientSocket;
@property (nonatomic,copy)NSMutableArray *clientSockets;
//计时器
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic,strong) NSTimer *changeColorTimer;
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

@end

@implementation TreatViewController
{
    BOOL isPlayButton;
    BOOL isPauseButton;
    TreatInformation *treatInfomation;
    RunningInfomation *runningInfomation;
    NSArray *bodyNames;
    NSMutableArray *bodyButtons;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self askForTreatInfomation];
    [self configureBodyView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    //连接服务器
    if (!self.connected)
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
    bodyNames= [NSArray arrayWithObjects:@"leftup1",@"leftup2",@"leftup3",@"lefthand",@"leftdown1",@"leftdown2",@"leftdown3",@"leftfoot",@"rightup1",@"rightup2",@"rightup3",@"righthand",@"rightdown1",@"rightdown2",@"rightdown3",@"rightfoot",@"middle1",@"middle2",@"middle3",@"middle4",nil];
    bodyButtons = [[NSMutableArray alloc]initWithCapacity:20];
    treatInfomation = [[TreatInformation alloc]init];
    runningInfomation = [[RunningInfomation alloc]init];
    [self configureView];
    [self configureBodyView];
}

-(void)viewWillDisappear:(BOOL)animated{
    for (int i=0; i<[bodyNames count]; i++)
    {
        [bodyButtons[i] removeFromSuperview];
    }
    //timer invalidate
//    [self.updateTimer invalidate];
//    self.updateTimer = nil;
    
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
        [treatInfomation analyzeWithData:data];
//        [treatInfomation addObserver:self forKeyPath:@"aPort" options:NSKeyValueObservingOptionNew context:nil];
//        [treatInfomation addObserver:self forKeyPath:@"bPort" options:NSKeyValueObservingOptionNew context:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureBodyView];
        });
    }
    //实时信息
    if (bytes[2]==0x91)
    {
        [runningInfomation analyzeWithData:data];
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
        self.warnningLabel.text = message;
    }

    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接 error:%@",err);
    self.clientSocket.delegate = nil;
    self.clientSocket = nil;
    self.connected = NO;
    [self.connectTimer invalidate];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//    if (tag == 1) {
//        NSLog(@"askForTreatMentInfoMATION写入成功");
//    }else if(tag == 2){
//        NSLog(@"-----------------------------------longconnectCheck写入成功");
//    }
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
    
    //加载身体部位按钮
    for (int i=0; i<[bodyNames count]; i++)
    {
        int tag = bodyPartTags[i];
        BodyButton *button = [self bodyButtonReturnWithTag:tag];
        [button setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"] forState:UIControlStateNormal];
        [bodyButtons addObject:button];
        [self.backgroundView addSubview:button];
        button.enabled = NO;
    }
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
    //button附带点亮模块的命令参数
    for (int i=0; i<[bodyNames count]; i++)
    {
        BodyButton *button = bodyButtons[i];
        button.enabled = NO;
        [button setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"] forState:UIControlStateNormal];
        button.multiParamDic = [NSMutableDictionary dictionaryWithDictionary:lightUpCommitDics[i]];
    }
    [self.progressView drawProgress:1];
    self.progressView.label.text = [NSString stringWithFormat:@"100%%"];

    
}
-(void)configureBodyView
{
    //改变前先让所以按钮变成灰色/取消定时器
    if (treatInfomation.treatState == Stop)
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
    //停止更新压力和进度圈UI
    if (treatInfomation.treatTime -1 == runningInfomation.treatProcessTime || treatInfomation.treatState == Stop)
    {
//        if (treatInfomation.treatTime -1 == runningInfomation.treatProcessTime)
//        {
            isPlayButton = YES;
            isPauseButton = NO;
            [self configurePlayButton];
//        }
        self.pressLabel.text = [NSString stringWithFormat:@"0"];
        [self.progressView drawProgress:1];
        self.progressView.label.text = [NSString stringWithFormat:@"100%%"];
    }
    else if(treatInfomation.treatState == Running||treatInfomation.treatState == Pause)
    {
        //treatInfomation.aPort != nil 确保收到了下位机的treatInfomation
        if (treatInfomation.treatState == Running && treatInfomation.aPort !=nil )
        {
            isPlayButton = NO;
            isPauseButton = YES;
            [self configurePlayButton];
        }
        else if(treatInfomation.treatState == Pause)
        {
            isPlayButton = YES;
            isPauseButton = NO;
            [self configurePlayButton];
        }
        //显示压力圈
        CGFloat currentProgress =(CGFloat)(runningInfomation.treatProcessTime)/(CGFloat)treatInfomation.treatTime;
        
        int progress = runningInfomation.treatProcessTime *100 / treatInfomation.treatTime;
        
        self.progressView.label.text = [NSString stringWithFormat:@"%d%%",(int)progress];
        [self.progressView drawProgress:currentProgress];
        NSString *press = runningInfomation.press[runningInfomation.curFocuse];
        self.pressLabel.text = [NSString stringWithFormat:@"%@",press];
    }
    
    
    //A端
    NSString *aport = treatInfomation.aPort;

    if ([aport isEqualToString:@"ARMA003"]) {   [self configureLeftWithType:@"ARMA003"];   }
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
    
    //B端
    NSString *bport = treatInfomation.bPort;
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
            if ([treatInfomation.enabled[i+1] isEqualToString:@"1" ])
            {
                if (treatInfomation.treatState == Running)
                {
                    NSInteger cellState = [runningInfomation.cellState[i+1] integerValue];
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
        if ([treatInfomation.enabled[0] isEqualToString:@"1"])
        {
            if (treatInfomation.treatState == Running)
            {
                NSInteger cellState = [runningInfomation.cellState[0] integerValue];
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
            [self enableButton:bodyButtons[lefthandindex]];
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
        if ([treatInfomation.enabled[0] isEqualToString:@"1"])
        {
 
            if (treatInfomation.treatState == Running)
            {
                NSInteger cellState = [runningInfomation.cellState[0] integerValue];
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
            [self enableButton:bodyButtons[leftfootindex]];
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

            if ([treatInfomation.enabled[i] isEqualToString:@"1" ])
            {
                if (treatInfomation.treatState == Running)
                {
                    NSInteger cellState = [runningInfomation.cellState[i]integerValue];
                    switch (cellState)
                    {
                        case UnWorking:
                            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
                            break;
                        case Working:
                            if (button.changeColorTimer == nil) {
                                [self startTimerToChangeColorOfButton:button];
                            }
                            break;
                        case KeepingAir:
                            if (button.changeColorTimer !=nil) {
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
            if ([treatInfomation.enabled[i+5] isEqualToString:@"1" ])
            {
                int index = indexArray[i];
                //                NSLog(@"treat state =%d",treatInfomation.treatState);
                if (treatInfomation.treatState == Running)
                {
                    
                    NSInteger cellState = [runningInfomation.cellState[i+5] integerValue];
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
        if ([treatInfomation.enabled[4] isEqualToString:@"1"])
        {
        
            if (treatInfomation.treatState == Running)
            {
                NSInteger cellState = [runningInfomation.cellState[4] integerValue];
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
            [self enableButton:bodyButtons[righthandindex]];
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
        if ([treatInfomation.enabled[4] isEqualToString:@"1"])
        {
            
            if (treatInfomation.treatState == Running)
            {
                NSInteger cellState = [runningInfomation.cellState[4] integerValue];
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
            [self enableButton:bodyButtons[rightfootindex]];
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
            if ([treatInfomation.enabled[i+4] isEqualToString:@"1" ])
            {
                if (treatInfomation.treatState == Running)
                {
                    NSInteger cellState = [runningInfomation.cellState[i+4]integerValue];
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
    [self configureBodyView];
}

-(BodyButton *)bodyButtonReturnWithTag:(NSInteger)tag
{
    BodyButton *button = [[BodyButton alloc]init];
    button.frame = [self.backgroundView viewWithTag:tag].frame;
    switch (tag) {
        case middle1tag:
        case middle2tag:
        case middle3tag:
        case middle4tag: [[button imageView]setContentMode:UIViewContentModeScaleToFill];
            break;
            
        default:[[button imageView]setContentMode:UIViewContentModeScaleAspectFit];
            break;
    }

    return button;
}

-(void)enableButton:(BodyButton *)button{
    button.enabled = YES;
    [button addTarget:self action:@selector(lightupBodyButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)configurePlayButton
{
    if (isPlayButton == YES) {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"stop_green"] forState:UIControlStateNormal];
    }
    
    if (isPauseButton) {
        
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_green"] forState:UIControlStateNormal];
        self.pauseButton.enabled = YES;
    }else{
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_write"] forState:UIControlStateNormal];
        self.pauseButton.enabled = NO;
    }
}

#pragma mark - commit
- (void)start
{
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {0,0x10};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    
    
//    NSString *messageString = @"aaaaaa";
//    NSData *data = [messageString dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
//    Byte *bytes = malloc(sizeof(*bytes)*[sendData length]);
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
}
-(void)pause
{
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] = {0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {0,0x11};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
//    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj writeData:sendData withTimeout:-1 tag:1];
//    }];
    
}
-(void)continue
{
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {0,0x12};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
}
-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {1,0x62};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:1];
}
-(void)lightupBodyButton:(BodyButton *)button
{
    [button changeGreyColor];
    NSNumber *commitNumber = [button.multiParamDic objectForKey:@"commit"];
    Pack *pack = [[Pack alloc]init];
    
    Byte dataBytes[2] = {0,[commitNumber unsignedIntegerValue]};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    
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
    
//    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
//                                                            target:self
//                                                          selector:@selector(updateBodyButton)
//                                                          userInfo:nil
//                                                           repeats:YES];
    //将定时器添加到当前运行循环，并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    Pack *pack =[[Pack alloc]init];
    NSData *sendData = [pack packetWithCmdid:0x93 addressEnabled:NO addr:nil dataEnabled:NO data:nil];
    [self.clientSocket writeData:sendData withTimeout:- 1 tag:2];
}

#pragma mark - Lazy Load
//- (NSMutableArray *)clientSockets
//{
//    if (_clientSockets == nil)
//    {
//        _clientSockets = [NSMutableArray array];
//    }
//    return _clientSockets;
//}

//- (NSMutableDictionary *)clientPhoneTimeDicts
//{
//    if (_clientPhoneTimeDicts == nil)
//    {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        _clientPhoneTimeDicts = dict;
//    }
//    return _clientPhoneTimeDicts;
//}

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

@end
