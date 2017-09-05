 //
//  TreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import <GCDAsyncSocket.h>
#import <GCDAsyncUdpSocket.h>
#import "TreatViewController.h"
#import "Pack.h"
#import "UINavigationController+statusBarStyle.h"
#import "TreatInformation.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]


@interface TreatViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
// 服务器socket(开放端口,监听客户端socket的连接)
@property(nonatomic,strong)GCDAsyncSocket *serverSocket;
// 保存客户端socket
@property (nonatomic,copy)NSMutableArray *clientSockets;
// 检测心跳计时器
@property (nonatomic, strong) NSTimer *checkTimer;
// 客户端标识和心跳接收时间的字典
@property (nonatomic, copy) NSMutableDictionary *clientPhoneTimeDicts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) IBOutlet UIView *buttonView;
- (IBAction)tapPlayButton:(id)sender;
- (IBAction)tapPauseButton:(id)sender;

@end

@implementation TreatViewController
{
    BOOL isPlayButton;
    BOOL isPauseButton;
    TreatInformation *treatInfomation;
}
-(void)viewWillAppear:(BOOL)animated
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    isPlayButton = YES;
    isPauseButton = NO;
    [self configurePlayButton];
    treatInfomation = [[TreatInformation alloc]init];
    
    // 开放哪一个端口
    NSError *error = nil;
    BOOL result = [self.serverSocket acceptOnPort:8080  error:&error];
    if (result && error == nil)
    {   NSLog(@"开放成功"); }
    else
    {   NSLog(@"已经开放"); }
    
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

//    设置右边的barButtonItem
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32 , 32)];
//    [btn setBackgroundImage:[UIImage imageNamed:@"1200916"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(rightBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = barButton;
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
- (void)start
{
    if (self.clientSockets == nil)
    {
        return;
    }
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
    Byte *bytes = (Byte *)[sendData bytes];
    for(int i=0;i<[sendData length];i++)
    {
        NSLog(@"bytes[%d]= %d",i,bytes[i]);
        
    }
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
    if (bytes[2]==144)
    {
        [treatInfomation analyzeWithData:data];
        NSLog(@"----treatInfomation%@",treatInfomation);
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
    if (_clientSockets == nil) {
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
