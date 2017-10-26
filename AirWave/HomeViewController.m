//
//  HomeViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/26.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "HomeViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigation
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //leftBarButton
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30 , 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu-2"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButton;
    
    //touchEnable

    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.imageView1 addGestureRecognizer:singleTap];
    [self.imageView2 addGestureRecognizer:singleTap];
    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
    
}
-(void)leftBarButtonClicked:(UIButton *)button
{
    
}
-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    NSLog(@"-----");
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.imageView1.alpha = 0.5;
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.imageView1.alpha = 1;
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.imageView1.alpha = 1;
}


@end
