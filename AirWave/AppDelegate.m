//
//  AppDelegate.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const HOST1 = @"10.10.100.254";
NSString *const POST1 = @"8080";


@interface AppDelegate ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, assign) BOOL cconnected;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError *error = nil;
    [self.cclientSocket connectToHost:HOST1 onPort:[POST1 integerValue] viaInterface:nil withTimeout:-1 error:&error];
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
