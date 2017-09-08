 //
//  TreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import <GCDAsyncSocket.h>
#import <GCDAsyncUdpSocket.h>

#import "Pack.h"
#import "BodyButton.h"
#import "TreatViewController.h"
#import "TreatInformation.h"
#import "UIImage+ImageWithColor.h"

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


typedef NS_ENUM(NSUInteger,BodyButtonIndexs) {
    leftup1index,leftup2index,leftup3index,lefthandindex,leftdown1index,leftdown2index,leftdown3index,leftfootindex,rightup1index,rightup2index,rightup3index,righthandindex,rightdown1index,rightdown2index,rightdown3index,rightfootindex,middle1index,middle2index,middle3index,middle4index
    
};
typedef NS_ENUM(NSUInteger,BodyTags) {
    leftup1tag   =17,leftup2tag   =16,leftup3tag   =15,lefthandtag  =14,leftdown1tag =13,leftdown2tag =12,leftdown3tag =11,
    leftfoottag  =10,rightup1tag  =27,rightup2tag  =26,rightup3tag  =25,righthandtag =24,rightdown1tag=23,rightdown2tag=22,
    rightdown3tag=21,rightfoottag =20,middle1tag   =33,middle2tag   =32,middle3tag   =31,middle4tag   =30
};
static int bodyPartTags[] = {leftup1tag,leftup2tag,leftup3tag,lefthandtag,leftdown1tag,leftdown2tag,leftdown3tag,leftfoottag,rightup1tag,rightup2tag,rightup3tag,righthandtag,rightdown1tag,rightdown2tag,rightdown3tag,rightfoottag,middle1tag,middle2tag,middle3tag,middle4tag};

NSString *const ARMB00 = @"ARMB004";

@interface TreatViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
// 服务器socket(开放端口,监听客户端socket的连接)
@property(nonatomic,strong)GCDAsyncSocket *serverSocket;
@property (nonatomic,copy)NSMutableArray *clientSockets;
@property (nonatomic, strong) NSTimer *checkTimer;
// 客户端标识和心跳接收时间的字典
@property (nonatomic, copy) NSMutableDictionary *clientPhoneTimeDicts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
- (IBAction)tapPlayButton:(id)sender;
- (IBAction)tapPauseButton:(id)sender;

@end

@implementation TreatViewController
{
    BOOL isPlayButton;
    BOOL isPauseButton;
    TreatInformation *treatInfomation;
    NSArray *bodyNames;
    NSMutableArray *bodyButtons;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self askForTreatInfomation];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isPlayButton = YES;
    isPauseButton = NO;
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:8080  error:&error];
    if (result && error == nil)
    {   NSLog(@"开放成功"); }
    else
    {   NSLog(@"已经开放"); }
    bodyNames= [NSArray arrayWithObjects:@"leftup1",@"leftup2",@"leftup3",@"lefthand",@"leftdown1",@"leftdown2",@"leftdown3",@"leftfoot",@"rightup1",@"rightup2",@"rightup3",@"righthand",@"rightdown1",@"rightdown2",@"rightdown3",@"rightfoot",@"middle1",@"middle2",@"middle3",@"middle4",nil];
    bodyButtons = [[NSMutableArray alloc]initWithCapacity:20];
    treatInfomation = [[TreatInformation alloc]init];
    [self askForTreatInfomation];
    [self configureView];
    
}
-(void)configureView
{
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.barBtItem.tintColor = UIColorFromHex(0xFFFFFF);
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
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

//    设置右边的barButtonItem
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32 , 32)];
//    [btn setBackgroundImage:[UIImage imageNamed:@"1200916"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(rightBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = barButton;
    
}
-(void)configureBodyView{
    
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
                                   @{@"position":@"middle1",   @"commit":[NSNumber numberWithUnsignedInteger:0x1d]}];
    //bodypart associate with lightupcommit
    for (int i=0; i<[bodyNames count]; i++) {
        BodyButton *button = bodyButtons[i];
        button.enabled = NO;
        [button setImage:[UIImage imageNamed:bodyNames[i] withColor:@"grey"] forState:UIControlStateNormal];
        button.multiParamDic = [NSMutableDictionary dictionaryWithDictionary:lightUpCommitDics[i]];
    }
    
    NSString *aport = treatInfomation.aPort;
    if ([aport isEqualToString:@"ARMA003"])
    {
        [self configureLeft3WithType:@"ARMA003"];
    }
    if ([aport isEqualToString:@"LEGA003"]) {
        [self configureLeft3WithType:@"LEGA003"];
    }
    if ([aport isEqualToString:@"ARMB004"]) {
        BodyButton *button = bodyButtons[lefthandindex];
        if ([treatInfomation.enabled[0] isEqualToString:@"1"]) {
            [button setImage:[UIImage imageNamed:bodyNames[lefthandindex] withColor:@"yellow"] forState:UIControlStateNormal];
        }
        [self enableButton:button];
        [self configureLeft3WithType:@"ARMA003"];
    }
    if ([aport isEqualToString:@"LEGA004"]) {
        BodyButton *button = bodyButtons[leftfootindex];
        if ([treatInfomation.enabled[0] isEqualToString:@"1"]) {
            [button setImage:[UIImage imageNamed:bodyNames[leftfootindex] withColor:@"yellow"] forState:UIControlStateNormal];
        }
        [self enableButton:button];
        [self configureLeft3WithType:@"LEGA003"];
    }
}
//-(void)configureLEGA003{
//    for (int i = leftdown1index; i<leftdown1index+3; i++) {
//        [self enableButton:bodyButtons[i]];
//    }
//    for (int i = 1; i<=3; i++) {
//        if ([treatInfomation.enabled[i] isEqualToString:@"1" ])
//        {
//            int indexArray [] = {leftdown1index,leftdown2index,leftdown3index};
//            for (int j = 0; j<3; j++) {
//                int index = indexArray[i];
//                [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
//            }
//            
//        }
//    }
//}
-(void)configureLeft3WithType:(NSString *)type{
    int indexArray[3];
    if ([type isEqualToString:@"ARMA003"]) {
        indexArray[0]= leftup3index;indexArray[1]=leftup2index;indexArray[2]=leftup1index;
    }
    if ([type isEqualToString:@"LEGA003"]) {
        indexArray[0]= leftdown3index;indexArray[1]=leftdown2index;indexArray[2]=leftdown1index;
    }
    int startIndex = indexArray[2];
    for (int i = startIndex; i<startIndex+3; i++) {
        [self enableButton:bodyButtons[i]];
    }
    for (int i = 1; i<=3; i++) {
        if ([treatInfomation.enabled[i] isEqualToString:@"1" ])
        {
            int index = indexArray[i-1];
            [bodyButtons[index] setImage:[UIImage imageNamed:bodyNames[index] withColor:@"yellow"] forState:UIControlStateNormal];
        }
    }
}
//-(void)configureARMA003{
//
//    for (int i = leftup1index; i<leftup1index+3; i++) {
//        [self enableButton:bodyButtons[i]];
//    }
//    if ([treatInfomation.enabled[1] isEqualToString:@"1"]) {
//        [bodyButtons[leftup3index]setImage:[UIImage imageNamed:@"leftup3" withColor:@"yellow"] forState:UIControlStateNormal];
//    }
//    if ([treatInfomation.enabled[2] isEqualToString:@"1"]) {
//        [bodyButtons[leftup2index] setImage:[UIImage imageNamed:@"leftup2" withColor:@"yellow"] forState:UIControlStateNormal];
//    }
//    if ([treatInfomation.enabled[3] isEqualToString:@"1"]) {
//        [bodyButtons[leftup1index] setImage:[UIImage imageNamed:@"leftup1" withColor:@"yellow"] forState:UIControlStateNormal];
//    }
//}
-(BodyButton *)bodyButtonReturnWithTag:(NSInteger)tag
{
    BodyButton *button = [[BodyButton alloc]init];
    button.frame = [self.backgroundView viewWithTag:tag].frame;
    [[button imageView]setContentMode:UIViewContentModeScaleAspectFit];
    return button;
}

-(void)enableButton:(UIButton *)button{
    button.enabled = YES;
    [button addTarget:self action:@selector(changeColorWithButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)changeColorWithButton:(BodyButton *)button
{
    
    NSString *imageName = [button.multiParamDic objectForKey:@"position"];
    NSNumber *commitNumber = [button.multiParamDic objectForKey:@"commit"];
    
    if ([button.currentImage isEqual:[UIImage imageNamed:imageName withColor:@"yellow"]])
    {
        [button setImage:[UIImage imageNamed:imageName withColor:@"grey"] forState:UIControlStateNormal];
    }else {
        [button setImage:[UIImage imageNamed:imageName withColor:@"yellow"] forState:UIControlStateNormal];
    }
    
    Pack *pack = [[Pack alloc]init];
    
    
    Byte dataBytes[2] = {0,[commitNumber unsignedIntegerValue]};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    
    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:sendData withTimeout:-1 tag:0];
    }];
    
    
}

-(void)configurePlayButton
{
    if (isPlayButton == YES) {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }
    
    if (isPauseButton) {
        
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_green"] forState:UIControlStateNormal];
        self.pauseButton.enabled = YES;
    }else{
        [self.pauseButton setImage:[UIImage imageNamed:@"pause_write"] forState:UIControlStateNormal];
        self.pauseButton.enabled = NO;
    }
}
//添加计时器
-(void)addTimer
{
    //长连接定时器
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkLongConnect) userInfo:nil repeats:YES];
    //将定时器添加到当前运行循环，并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.checkTimer forMode:NSRunLoopCommonModes];
}
//检测心跳
-(void)checkLongConnect
{
    [self.clientPhoneTimeDicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *currentTimeStr = [self getCurrentTime];
        //延迟超多10s判断断开
        if (([currentTimeStr doubleValue] - [obj doubleValue] ) > 10.0)
        {
            NSLog(@"%@已断开连接，连接时差%f",key,([currentTimeStr doubleValue]-[obj doubleValue]));
        }
        else
        {
            NSLog(@"%@处于连接状态，连接时差%f",key,([currentTimeStr doubleValue]-[obj doubleValue]));
        }
        
    }];
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
    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:sendData withTimeout:-1 tag:0];
    }];
}
-(void)pause
{
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] = {0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {0,0x11};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    
    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:sendData withTimeout:-1 tag:1];
    }];
}
-(void)continue
{
    Pack *pack = [[Pack alloc]init];
    
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {0,0x12};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:sendData withTimeout:-1 tag:2];
    }];

}
-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] ={0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    Byte dataBytes[2] = {1,0x62};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSockets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj writeData:sendData withTimeout:-1 tag:3];
    }];
}


#pragma mark - 服务器socketDelegate
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    
    [self.clientSockets addObject:newSocket];
    
    [self addTimer];
    NSLog(@"连接成功");
    NSLog(@"客户端的地址%@ 端口%d",newSocket.connectedHost,newSocket.connectedPort);
    
    [self askForTreatInfomation];
    [newSocket readDataWithTimeout:-1 tag:0];
    
}

/**
 读取客户端的数据
 
 @param sock 客户端的Socket
 @param data 客户端发送的数据
 @param tag 当前读取的标记
 */
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text;
    Byte *bytes = (Byte *)[data bytes];
//    for(int i=0;i<[data length];i++)
//    {
//        text =[NSString stringWithFormat:@"%d",bytes[2]];
//        if (bytes[2]!=147)
//        {
//            NSLog(@"bytes[%d]= %d",i,bytes[i]);
//            NSLog(@"receive string %@",text);
//        }
//    }
    text = [NSString stringWithFormat:@"%d",bytes[2]];
    if (bytes[2]==0x90)
    {
        [treatInfomation analyzeWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureBodyView];
        });
    }
//    NSStringEncoding myEncoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
//    
//    NSString *text = [[NSString alloc]initWithData:data encoding:myEncoding];
    
//    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    // 第一次读取到的数据直接添加
    if (self.clientPhoneTimeDicts.count == 0)
    {
        
        [self.clientPhoneTimeDicts setObject:[self getCurrentTime] forKey:text];
    }
    else
    {
        [self.clientPhoneTimeDicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.clientPhoneTimeDicts setObject:[self getCurrentTime] forKey:text];
        }];
    }

    [sock readDataWithTimeout:- 1 tag:0];
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [self.clientSockets removeObject:sock];
    NSLog(@"断开连接 error:%@",err);
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"写入成功");
}
#pragma mark - Lazy Load
- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil)
    {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}

- (NSMutableDictionary *)clientPhoneTimeDicts
{
    if (_clientPhoneTimeDicts == nil)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        _clientPhoneTimeDicts = dict;
    }
    return _clientPhoneTimeDicts;
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

-(UIColor *)colorFromHexRGB:(NSString *)rgb
{
    UInt32 hex = [rgb intValue];
    int r = (hex >>16) &0xFF;
    
    int g = (hex >>8) &0xFF;
    
    int b = (hex) &0xFF;
    
    return[UIColor colorWithRed:r /255.0f
           
                          green:g /255.0f
           
                           blue:b /255.0f
           
                          alpha:1.0f];
}
//-(NSData *)newDataWithbyte:(Byte)byte1 andByte:(Byte)byte2{
//    
//}

-(CATransition *)createTransitionAnimation
{
    //切换之前添加动画效果
    //后面知识: Core Animation 核心动画
    //不要写成: CATransaction
    //创建CATransition动画对象
    CATransition *animation = [CATransition animation];
    //设置动画的类型:
    animation.type = @"rippleEffect";
    //设置动画的方向
    animation.subtype = kCATransitionFromBottom;
    //设置动画的持续时间
    animation.duration = 1.5;
    //设置动画速率(可变的)
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //动画添加到切换的过程中
    return animation;
}

- (IBAction)tapPlayButton:(id)sender
{
    [self.playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    isPlayButton  = !isPlayButton;
    isPauseButton = !isPauseButton;
    [self configurePlayButton];
    [self start];
    
}

- (IBAction)tapPauseButton:(id)sender {
    [self continue];
    isPlayButton  = !isPlayButton;
    isPauseButton = !isPauseButton;
    [self pause];
    [self configurePlayButton];
}
@end
