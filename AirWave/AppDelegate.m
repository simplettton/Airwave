//
//  AppDelegate.m
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "MMdrawerVisualState.h"
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
NSString *const HOST1 = @"10.10.100.254";
NSString *const POST1 = @"8080";

@interface AppDelegate ()<GCDAsyncSocketDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initDrawer];
    return YES;
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
-(void)initDrawer
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *centralNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"centerNav"];
    
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu"];
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
