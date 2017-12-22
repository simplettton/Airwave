//
//  AppDelegate.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import <UMSocialCore/UMSocialCore.h>
#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "MMdrawerVisualState.h"
#import "LeftDrawerViewController.h"
#import "Pack.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const USHARE_APPKEY = @"5a2a0fdeb27b0a4989000164";
@interface AppDelegate ()<GCDAsyncSocketDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configAirWaveNetworkSetting];
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
    
    [self configUSharePlatforms];
    
    [self configUShareSettings];
    
    [self initDrawer];

    return YES;
}
-(void)configAirWaveNetworkSetting
{
    self.host = @"10.10.100.254";
    self.port = @"8080";
}
- (void)configUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}
-(void)configUSharePlatforms
{
    /*
     设置新浪的appKey和appSecret
     [新浪微博集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_2
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
                                          appKey:@"3302431209"
                                       appSecret:@"3eb44f6ec3446dd815100753e70decfb"
                                     redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:@"wx4b2322692fe85433"
                                       appSecret:@"427ac81412594ef7b7c6921d7d1dc070"
                                     redirectURL:@"http://mobile.umeng.com/social"];
}
// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    NSError *error = nil;
//    [self.cclientSocket connectToHost:self.host onPort:[self.port integerValue] viaInterface:nil withTimeout:-1 error:&error];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSError *error = nil;
    if (!self.cconnected)
    {
        [self.cclientSocket connectToHost:self.host onPort:[self.port integerValue] viaInterface:nil withTimeout:-1 error:&error];
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
-(void)initDrawer
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *centralNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"centerNav"];
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu"];
    
//    UIViewController *leftViewController = [[LeftDrawerViewController alloc]init];
    [centralNavi setRestorationIdentifier:@"CentralNavigationControllerRestorationKey"];
    [leftViewController setRestorationIdentifier:@"LeftViewControllerRestorationKey"];
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:centralNavi leftDrawerViewController:leftViewController];
    //重用 标识
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    
    [self.drawerController setDrawerVisualStateBlock:[MMDrawerVisualState slideAndScaleVisualStateBlock]];
    [self.drawerController setMaximumLeftDrawerWidth:260.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = self.drawerController;
}

@end
