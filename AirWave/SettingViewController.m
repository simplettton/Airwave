//
//  SettingViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/28.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SettingViewController.h"
#import "OtherSettingViewController.h"
#import "TreatInformation.h"
#import "AppDelegate.h"
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
typedef NS_ENUM(NSUInteger,ButtonTags)
{
    restoreFactoryBtnTag = 1000,cancelChangeBtnTag = 2000,saveBtnTag = 3000
};
@interface SettingViewController ()<GCDAsyncSocketDelegate>

@property (strong,nonatomic) GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UILabel *keepTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeSpeedLabel;
@property (weak, nonatomic) IBOutlet UIStepper *keepTimeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *intervalTimeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *chargeSpeedStepper;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
- (IBAction)save:(id)sender;
- (IBAction)cancelChange:(id)sender;
- (IBAction)restoreFactorySetting:(id)sender;
- (IBAction)returnToMain:(id)sender;

@end

@implementation SettingViewController

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color
{
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.treatInfomation == nil)
    {
        self.treatInfomation = [[TreatInformation alloc]init];
    }
//    [self updateView];
    
    //设置边框
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.keepTimeLabel.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.keepTimeLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    maskLayer.lineWidth = 1.0;
    maskLayer.strokeColor = UIColorFromHex(0xe7e8e7).CGColor;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    [self.keepTimeLabel.layer addSublayer:maskLayer];
    
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.intervalTimeLabel.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = self.intervalTimeLabel.bounds;
    maskLayer1.path = maskPath1.CGPath;
    maskLayer1.lineWidth = 1.0;
    maskLayer1.strokeColor = UIColorFromHex(0xe7e8e7).CGColor;
    maskLayer1.fillColor = [UIColor clearColor].CGColor;
    [self.intervalTimeLabel.layer addSublayer:maskLayer1];
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.chargeSpeedLabel.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.frame = self.chargeSpeedLabel.bounds;
    maskLayer2.path = maskPath2.CGPath;
    maskLayer2.lineWidth = 1.0;
    maskLayer2.strokeColor = UIColorFromHex(0xe7e8e7).CGColor;
    maskLayer2.fillColor = [UIColor clearColor].CGColor;
    [self.chargeSpeedLabel.layer addSublayer:maskLayer2];
    
    [self.keepTimeStepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.intervalTimeStepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.chargeSpeedStepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *mydelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.clientSocket = mydelegate.cclientSocket;
    self.clientSocket.delegate = self;
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    [self askForTreatInfomation];
}
-(void)updateView
{
    self.keepTimeLabel.text =[NSString stringWithFormat:@"%d",self.treatInfomation.keepTime];
    self.keepTimeStepper.value = self.treatInfomation.keepTime;

    
    self.intervalTimeLabel.text = [NSString stringWithFormat:@"%d",self.treatInfomation.treatInterval];
    self.intervalTimeStepper.value = self.treatInfomation.treatInterval;

    
    self.chargeSpeedLabel.text = [NSString stringWithFormat:@"%d",self.treatInfomation.chargeSpeed];
    self.chargeSpeedStepper.value = self.treatInfomation.chargeSpeed;

}
-(void)valueChanged:(id)sender
{
    if([sender isEqual:self.keepTimeStepper])
    {
        self.keepTimeLabel.text = [NSString stringWithFormat:@"%d",(int)self.keepTimeStepper.value];
    }else if ([sender isEqual:self.intervalTimeStepper]){
        self.intervalTimeLabel.text = [NSString stringWithFormat:@"%d",(int)self.intervalTimeStepper.value];
    }else if ([sender isEqual:self.chargeSpeedStepper]){
        self.chargeSpeedLabel.text = [NSString stringWithFormat:@"%d",(int)self.chargeSpeedStepper.value];
    }
}
-(void)askForTreatInfomation
{
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {1,0x62};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                               dataEnabled:YES data:[self dataWithBytes:dataBytes]] withTimeout:-1 tag:0];
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
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault
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
#pragma mark - delegate

- (IBAction)sendData:(id)sender
{
    Byte addr[]={0x06,0x23};
    Byte data[] = {0xf1,0};
    Byte dataBytes [2] = {0xae,0};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr] dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:0];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]    dataEnabled:YES data:[self dataWithBytes:dataBytes]] withTimeout:-1 tag:3000];
}

- (IBAction)save:(id)sender
{
    
    Byte data[] = {0,0};
    //设置保持时间
    Byte addr[] = {80,2};
    data[0]= [self.keepTimeLabel.text integerValue];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr]dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:1];
    
    //设置间隔时间
    
    Byte addr1[] = {2,19};
    data[0] = [self.intervalTimeLabel.text integerValue];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr1]dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:1];
 
    //设置充气时间
    Byte addr2[] = {2,27};
    data[0] = [self.chargeSpeedLabel.text integerValue];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr2]dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:1];
}

- (IBAction)cancelChange:(id)sender
{
    Byte data[] = {0,0};
    data[0] = 0xba;
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:0];
    data[0] = 0xae;
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:0];
//    [self performSegueWithIdentifier:@"SettingToMain" sender:nil];
    [self returnToMain:sender];
}

- (IBAction)restoreFactorySetting:(id)sender
{
    NSString *title = @"恢复出厂设置";
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    //修改提示标题的颜色和大小
    NSMutableAttributedString *titleAtt = [[NSMutableAttributedString alloc] initWithString:title];
    [titleAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];
    [titleAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, title.length)];
    [alert setValue:titleAtt forKey:@"attributedTitle"];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              Byte addr[] = {0x04,0x23};
                                                              Byte dataBytes [] = {1,0};
                                                              NSData *data = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr]dataEnabled:YES data:[self dataWithBytes:dataBytes]];
                                                              [self.clientSocket writeData:data withTimeout:-1 tag:1000];
                    
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];

}
#pragma mark - private method
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self askForTreatInfomation];
    if ([segue.identifier isEqualToString:@"SettingToOtherSetting"])
    {
        OtherSettingViewController *controller = (OtherSettingViewController *)segue.destinationViewController;
        controller.treatInfomation = self.treatInfomation;
        Byte dataBytes[2] = {0xb2,0};
        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithBytes:dataBytes]] withTimeout:-1 tag:0];
    }
}
- (IBAction)returnToMain:(id)sender
{
    [self askForTreatInfomation];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    Byte addr[] = {0x06,0x23};
    Byte data[] = {0,0};
    data[0] = 0xf1;
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr] dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:0];
    data[0] = 0xae;
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]    dataEnabled:YES data:[self dataWithBytes:data]] withTimeout:-1 tag:0];
}
@end
