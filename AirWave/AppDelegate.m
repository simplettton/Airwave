//
//  AppDelegate.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const HOST1 = @"10.10.100.254";
NSString *const POST1 = @"8080";


@interface AppDelegate ()<GCDAsyncSocketDelegate>
@property (nonatomic,assign)BOOL cconnected;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self connectToServer];
    return YES;;
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接 error:%@",err);
    self.cclientSocket.delegate = nil;
    self.cclientSocket = nil;
    self.cconnected = NO;
    [self connectToServer];
}
-(void)connectToServer
{
    if (!self.cconnected)
    {
        self.cclientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSLog(@"开始连接%@",self.cclientSocket);
        
        NSError *error = nil;
        self.cconnected = [self.cclientSocket connectToHost:HOST1 onPort:[POST1 integerValue] viaInterface:nil withTimeout:-1 error:&error];
        if (self.cconnected)
        {
            NSLog(@"客户端尝试连接");
        }
        else
        {
            self.cconnected = NO;
            NSLog(@"客户端未创建连接");
        }
    }
    else
    {
        NSLog(@"与服务器连接已建立");
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSError *error = nil;
    [self.cclientSocket connectToHost:HOST1 onPort:[POST1 integerValue] viaInterface:nil withTimeout:-1 error:&error];

}


- (void)applicationWillTerminate:(UIApplication *)application
{

}


@end
