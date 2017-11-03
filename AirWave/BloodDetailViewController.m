//
//  DeviceDetailViewController.m
//  LifotronicFamily
//
//  Created by simplettton on 2017/7/31.
//  Copyright © 2017年 Simplettton. All rights reserved.
//

#import "BloodDetailViewController.h"

@interface BloodDetailViewController ()

@end

@implementation BloodDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setBorder];
    // Do any additional setup after loading the view.
}
-(void)setBorder
{
    self.Label1.layer.borderWidth = 0.5;
    self.Label1.layer.borderColor = [[UIColor grayColor]CGColor];
    self.Label2.layer.borderWidth = 0.5;
    self.Label2.layer.borderColor = [[UIColor grayColor]CGColor];
}
@end
