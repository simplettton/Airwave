//
//  LoginViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
- (IBAction)closeSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    

//      [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]animated:YES];
}

@end
