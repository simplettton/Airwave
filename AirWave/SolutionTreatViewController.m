//
//  SolutionTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/9/1.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import "SolutionTreatViewController.h"
#import "TreatViewController.h"
#import "TreatInformation.h"
#import "AppDelegate.h"
#import "Pack.h"
#import <GCDAsyncSocket.h>
#import <SVProgressHUD.h>
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]

@interface SolutionTreatViewController ()<GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket *clientSocket;
@property (nonatomic,  weak) IBOutlet UIView *buttonView;
@property (nonatomic,  weak) IBOutlet UIStepper *stepper;
@property (nonatomic,  weak) IBOutlet UIView *backgroundView;
@property (nonatomic,  weak) IBOutlet UITextField *pressTextField;
@property (nonatomic,) NSInteger selectedModeTag;
- (IBAction)onClick:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)returnToMain:(id)sender;

@end

@implementation SolutionTreatViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.treatInfomation == nil)
    {
        self.treatInfomation = [[TreatInformation alloc]init];
    }
    self.pressTextField.text = [NSString stringWithFormat:@"100"];
    self.stepper.value = 100;
    self.stepper.minimumValue = 0;
    self.stepper.maximumValue = 240.0;
    self.stepper.tintColor = UIColorFromHex(0x65BBA9);

    [self updateView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self configureView];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.clientSocket = myDelegate.cclientSocket;
    self.clientSocket.delegate = self;
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    [self askForTreatInfomation];
}
-(void)configureView
{
    //导航栏

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x626d91)}];
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xffffff);
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationItem.hidesBackButton = YES;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
    
    self.saveButton.layer.borderWidth = 0.8;
    self.saveButton.layer.borderColor = UIColorFromHex(0x85ABE4).CGColor;
    
}
-(void)updateView
{
    //stepper
    self.stepper.value = [self.treatInfomation.press[0]integerValue];
    [self.stepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];

    if (myDelegate.cconnected)
    {
        self.pressTextField.text = [NSString stringWithFormat:@"%ld",(long)self.stepper.value];
    }

    //select button
    for (int i = 1; i<11; i++)
    {
        [self.backgroundView viewWithTag:i].layer.borderColor = UIColorFromHex(0X65BBA9).CGColor;
        [self.backgroundView viewWithTag:i].layer.borderWidth = 1.5;
        //处理不可按的按钮
        NSString *aport = self.treatInfomation.aPort;
        NSString *bport = self.treatInfomation.bPort;
        NSArray *unableBtnTag = @[@"4",@"5",@"6",@"9",@"10"];
        if ([aport isEqualToString:@"NONA000"]||[bport isEqualToString:@"NONB000"])
        {
            UIButton *button;
            for (NSString *tag in unableBtnTag )
            {
                
                button =(UIButton *)[self.backgroundView viewWithTag:[tag integerValue]];
                button.layer.borderColor = UIColorFromHex(0xDDE4EE).CGColor;
                button.layer.backgroundColor = UIColorFromHex(0xDDE4EE).CGColor;
                button.layer.borderWidth = 1.5;
                button.enabled = NO;
            }
            if([aport isEqualToString:@"ABDA004"]||[bport isEqualToString:@"ABDB004"])
            {
                for (int i =1; i<4; i++)
                {
                    button = (UIButton*)[self.backgroundView viewWithTag:i];
                    button.layer.borderColor = UIColorFromHex(0xDDE4EE).CGColor;
                    button.layer.backgroundColor = UIColorFromHex(0xDDE4EE).CGColor;
                    button.layer.borderWidth = 1.5;
                    button.enabled = NO;
                }
            }
        }
    }
}
-(void)valueChanged:(id)sender
{
    self.pressTextField.text = [NSString stringWithFormat:@"%d",(int)self.stepper.value];
}

- (IBAction)tapGradientTreat:(id)sender
{
    UILabel *warningLabel = [[UILabel alloc]init];
    warningLabel.textAlignment = NSTextAlignmentLeft;
    warningLabel.text = @"气囊类型不合适";
    warningLabel.textColor = UIColorFromHex(0xFF8247);
    UIImageView *warningImageView = [[UIImageView alloc]init];
    warningImageView.image = [UIImage imageNamed:@"warning"];
    [self.backgroundView addSubview:warningImageView];
    [self.backgroundView addSubview:warningLabel];
    
    warningLabel.translatesAutoresizingMaskIntoConstraints = NO;
    warningImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //--------------------------------------warningLabel---------------------------------------
    //width约束
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:135];
    //height约束
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:35];
    [warningLabel addConstraints:@[widthConstraint,heightConstraint]];
    
    //添加centerX约束
    NSLayoutConstraint *centerXConstraint =[NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    //添加button约束
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:warningLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.backgroundView addConstraints:@[centerXConstraint,bottomConstraint]];
    //--------------------------------------warningImageView-------------------------------------
    //width约束
    NSLayoutConstraint *widthConstraint1 = [NSLayoutConstraint constraintWithItem:warningImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:35];
    //height约束
    NSLayoutConstraint *heightConstraint1 = [NSLayoutConstraint constraintWithItem:warningImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:35];
    [warningImageView addConstraints:@[widthConstraint1,heightConstraint1]];
    //centerY约束
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:warningImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:warningLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    //left约束
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:warningImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:warningLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:6];
    [self.backgroundView addConstraints:@[centerYConstraint,rightConstraint]];
    
    //增加闪动动画
    [warningImageView.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    [warningLabel.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    // 延迟后警告消失
    int64_t delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [warningLabel removeFromSuperview];
        [warningImageView removeFromSuperview];
    });
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
    self.selectedModeTag = [(UIButton *)sender tag];
    for (int i = 1; i<11; i++)
    {
        UIButton *btn = (UIButton *)[self.backgroundView viewWithTag:i];
        if (btn.tag == [(UIButton *)sender tag])
        {
            btn.backgroundColor = UIColorFromHex(0X65BBA9);
            
        }
        else
        {
            if(btn.enabled == YES)
            {
                btn.backgroundColor = [UIColor whiteColor];
                btn.layer.borderColor = UIColorFromHex(0X65BBA9).CGColor;
                btn.layer.borderWidth = 1.5;
            }
        }
    }
}

- (IBAction)save:(id)sender
{
    NSArray *modeSettingDics = @[  @{@"tag":@"1",   @"commit":[NSNumber numberWithUnsignedInteger:0x89]},
                                   @{@"tag":@"2",   @"commit":[NSNumber numberWithUnsignedInteger:0x8a]},
                                   @{@"tag":@"3",   @"commit":[NSNumber numberWithUnsignedInteger:0x8b]},
                                   @{@"tag":@"4",   @"commit":[NSNumber numberWithUnsignedInteger:0xbc]},
                                   @{@"tag":@"5",   @"commit":[NSNumber numberWithUnsignedInteger:0xbd]},
                                   @{@"tag":@"6",   @"commit":[NSNumber numberWithUnsignedInteger:0xbe]},
                                   @{@"tag":@"7",   @"commit":[NSNumber numberWithUnsignedInteger:0xbf]},
                                   @{@"tag":@"8",   @"commit":[NSNumber numberWithUnsignedInteger:0xc0]},
                                   @{@"tag":@"9",   @"commit":[NSNumber numberWithUnsignedInteger:0xc1]},
                                   @{@"tag":@"10",  @"commit":[NSNumber numberWithUnsignedInteger:0xc2]}    ];
    for(NSDictionary *dic in modeSettingDics)
    {
        if (self.selectedModeTag == [[dic objectForKey:@"tag"]integerValue])
        {
            NSInteger commit = [[dic objectForKey:@"commit"]unsignedIntegerValue];
            NSData *dataToSend = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithValue:commit]];
            [self.clientSocket writeData:dataToSend withTimeout:-1 tag:1];
            NSData *saveCommand = [Pack packetWithCmdid:0X90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithValue:0xbb]];
            [self.clientSocket writeData:saveCommand withTimeout:-1 tag:1];
        }
    }
    //设置治疗压力
    NSInteger press= [self.pressTextField.text integerValue];
    NSData *sendData = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:80]
                                  dataEnabled:YES data:[self dataWithValue:press]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:1];
}

- (IBAction)returnToMain:(id)sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
}

#pragma mark - SocketDelegate
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        NSString *title = @"保存成功";
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        //修改提示标题的颜色和大小
        NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
        [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
        [alert setValue:titleAtt forKey:@"attributedTitle"];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text;
    Byte *bytes = (Byte *)[data bytes];
    
    text = [NSString stringWithFormat:@"%d",bytes[2]];
    //治疗信息
    if (bytes[2]==0x90)
    {
        [self.treatInfomation analyzeWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateView];
        });
    }
    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接 error:%@",err);
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cconnected = NO;
    myDelegate.cclientSocket=nil;
    NSString *wifiName = myDelegate.wifiName;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"断开连接 %@",wifiName!=nil?wifiName:@"空气波"]];
    [SVProgressHUD dismissWithDelay:0.9];
}

-(void)askForTreatInfomation
{
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:0x6201]] withTimeout:-1 tag:1000];
}
#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (segue.identifier != nil)
    {

        NSData *sendata;
        if ([segue.identifier isEqualToString: @"SolutionToStandard"])
        {
            sendata = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                dataEnabled:YES data:[self dataWithValue:0x0d]];
        }
        else if ([segue.identifier isEqualToString:@"SolutionToParameter"])
        {
            [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                   dataEnabled:YES data:[self dataWithValue:0x0f]] withTimeout:-1 tag:0];
            sendata = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                dataEnabled:YES data:[self dataWithValue:0x82]];
        }
        [self.clientSocket writeData:sendata withTimeout:-1 tag:0];
    }
}


@end
