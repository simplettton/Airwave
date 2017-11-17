//
//  LoginViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"
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
- (IBAction)login:(id)sender;
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
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    [params setObject:username forKey:@"Username"];
    [params setObject:password forKey:@"Pwd"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[HttpHelper instance] post:@"Login"
                            params:params
                          hasToken:NO
                        onResponse:^(HttpResponse *responseObject) {
                            NSDictionary* jsonDict = [responseObject jsonDist];
                            if (jsonDict != nil)
                            {
                                int state = [[jsonDict objectForKey:@"State"] intValue];
                                if (state == 1)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                                        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
                                        [SVProgressHUD setBackgroundColor:[UIColor lightGrayColor]];
                                        [SVProgressHUD dismissWithDelay:0.9];
                                    });
                                }
                                NSString *permission = [jsonDict objectForKey:@"Power"];
                                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                                [userDefault setObject:permission forKey:@"permission"];
                            }
                        }
                            onError:nil];
    });
}
@end
