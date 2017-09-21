//
//  SolutionTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/9/1.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SolutionTreatViewController.h"
#import "AppDelegate.h"
#import "Pack.h"
#import <GCDAsyncSocket.h>
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]

@interface SolutionTreatViewController ()<GCDAsyncSocketDelegate>
@property (strong,nonatomic)GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;
@property (weak, nonatomic) IBOutlet UITextField *pressTextField;
- (IBAction)onClick:(id)sender;
@end

@implementation SolutionTreatViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.clientSocket = myDelegate.cclientSocket;
    self.clientSocket.delegate = self;
}
-(void)configureView
{
    //导航栏
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x626d91)}];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
    
    //stepper
    self.stepper.minimumValue = 0;
    self.stepper.maximumValue = 240.0;
    self.stepper.tintColor = UIColorFromHex(0x65BBA9);
    self.stepper.value = [self.treatInfomation.press[0]doubleValue];
    [self.stepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    self.pressTextField.text = [NSString stringWithFormat:@"%ld",(long)[self.treatInfomation.press[0] integerValue]];
    
    //button
    
    
//    [self.backgroudView viewWithTag:11].backgroundColor = UIColorFromHex(0x65BBA9);
    for (int i = 1; i<17; i++) {
        [self.backgroudView viewWithTag:i].layer.borderColor = UIColorFromHex(0x65BBA9).CGColor;
        [self.backgroudView viewWithTag:i].layer.borderWidth = 2.0;
    }
}
-(void)valueChanged:(id)sender
{
    self.pressTextField.text = [NSString stringWithFormat:@"%d",(int)self.stepper.value];
}












- (IBAction)tapGradientTreat:(id)sender
{
    UILabel *warningLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 509, 135, 35)];
    // warningLabel.backgroundColor = UIColorFromHex(0xF7F8F8);
    warningLabel.textAlignment = NSTextAlignmentLeft;
    warningLabel.text = @"气囊类型不合适";
    warningLabel.textColor = UIColorFromHex(0xFF8247);
    
    UIImageView *warningImageView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 509, 35, 35)];
    warningImageView.image = [UIImage imageNamed:@"warning"];
    [[self.view viewWithTag:1000] addSubview:warningImageView];
    [[self.view viewWithTag:1000] addSubview:warningLabel];
    [warningImageView.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    [warningLabel.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    // 延迟2s后警告消失
    int64_t delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [warningLabel removeFromSuperview];
        [warningImageView removeFromSuperview];
    });
}
#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (segue.identifier != nil)
    {
        Pack *pack = [[Pack alloc]init];
        NSData *sendata;
        if ([segue.identifier isEqualToString: @"SolutionToStandard"])
        {
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                    dataEnabled:YES data:[self dataWithValue:0x0d]];
            
        }
        else if ([segue.identifier isEqualToString:@"SolutionToParameter"])
        {
            NSData *switchModeData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                                   dataEnabled:YES data:[self dataWithValue:0x0f]];
            [self.clientSocket writeData:switchModeData withTimeout:-1 tag:0];
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                    dataEnabled:YES data:[self dataWithValue:0X82]];
        }
        [self.clientSocket writeData:sendata withTimeout:-1 tag:0];

    }
}
#pragma mark - private method
-(CABasicAnimation *)warningMessageAnimation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 4.0f;
    animation.removedOnCompletion = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    return animation;
}
-(NSData*) dataWithValue:(NSInteger)value
{
    Byte src[2]={0,0};
    src[0] =  (Byte) ((value>>8) & 0xFF);
    src[1] =  (Byte) (value & 0xFF);
    NSData *data = [NSData dataWithBytes:src length:2];
    return data;
}
-(NSData*) dataWithBytes:(Byte[])bytes
{
    NSData *data = [NSData dataWithBytes:bytes length:2];
    return data;
}

- (IBAction)onClick:(id)sender
{
    for (int i = 1; i<17; i++)
    {
        UIButton *btn = (UIButton *)[self.backgroudView viewWithTag:i];
        if (btn.tag == [(UIButton *)sender tag])
        {
            btn.backgroundColor = UIColorFromHex(0x65BBA9);
        }
        else
        {
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.borderColor = UIColorFromHex(0x65BBA9).CGColor;
            btn.layer.borderWidth = 2;
        }
    }
}
@end
