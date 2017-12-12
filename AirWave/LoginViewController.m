//
//  LoginViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"

#import <SVProgressHUD.h>

#import <UMSocialCore/UMSocialCore.h>
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
#import "HttpHelper.h"
#import "SVProgressHUD.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (IBAction)login:(id)sender;
- (IBAction)loginWithSina:(id)sender;
- (IBAction)loginWithWeChat:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = barButton;
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0x65BBA9);
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
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
}


- (IBAction)login:(id)sender
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSString *username = self.userNameTextField.text;
//    NSString *password = self.passwordTextField.text;
//    [params setObject:username forKey:@"Username"];
//    [params setObject:password forKey:@"Pwd"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[HttpHelper instance] post:@"Login"
//                            params:params
//                          hasToken:NO
//                        onResponse:^(HttpResponse *responseObject) {
//                            NSDictionary* jsonDict = [responseObject jsonDist];
//                            if (jsonDict != nil)
//                            {
//                                int state = [[jsonDict objectForKey:@"State"] intValue];
//                                if (state == 1)
//                                {
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
//                                        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//                                        [SVProgressHUD setBackgroundColor:[UIColor lightGrayColor]];
//                                        [SVProgressHUD dismissWithDelay:0.9];
//                                    });
//                                }
//                                NSString *permission = [jsonDict objectForKey:@"Power"];
//                                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//                                [userDefault setObject:permission forKey:@"permission"];
//                            }
//                        }
//                            onError:nil];
//    });
    [self getAuthWithUserInfoFromSina];
}

- (IBAction)loginWithSina:(id)sender
{
    [self getAuthWithUserInfoFromSina];
}

- (IBAction)loginWithWeChat:(id)sender
{
    [self getAuthWithUserInfoFromWechat];
}
- (void)getAuthWithUserInfoFromSina
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error = %@",error);
            
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"Sina uid: %@", resp.uid);
            NSLog(@"Sina accessToken: %@", resp.accessToken);
            NSLog(@"Sina refreshToken: %@", resp.refreshToken);
            NSLog(@"Sina expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"Sina name: %@", resp.name);
            NSLog(@"Sina iconurl: %@", resp.iconurl);
            NSLog(@"Sina gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSLog(@"Sina originalResponse: %@", resp.originalResponse);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSString *imageURL = resp.iconurl;
//            UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
            
            //保存头像
            [userDefaults setObject:imageURL forKey:@"imageURL"];
            //保存昵称
            [userDefaults setObject:resp.name forKey:@"name"];
            //保存性别
            [userDefaults setObject:resp.unionGender forKey:@"sex"];
            
            [userDefaults synchronize];
            
            NSString *string = [NSString stringWithFormat:@"%@,%@",resp.name,resp.unionGender];
            dispatch_async(dispatch_get_main_queue(), ^{

//                [self.iconImageView setImage:image];
                [SVProgressHUD showSuccessWithStatus:string];
            });
        }
    }];
}
- (void)getAuthWithUserInfoFromWechat
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"Wechat uid: %@", resp.uid);
            NSLog(@"Wechat openid: %@", resp.openid);
            NSLog(@"Wechat unionid: %@", resp.unionId);
            NSLog(@"Wechat accessToken: %@", resp.accessToken);
            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
            NSLog(@"Wechat expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"Wechat name: %@", resp.name);
            NSLog(@"Wechat iconurl: %@", resp.iconurl);
            NSLog(@"Wechat gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSString *string = [NSString stringWithFormat:@"%@,%@",resp.name,resp.unionGender];
            [SVProgressHUD showSuccessWithStatus:string];
        }
    }];
}
@end
