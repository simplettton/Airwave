//
//  OtherSettingViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/28.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "OtherSettingViewController.h"
#import "AppDelegate.h"
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface OtherSettingViewController ()<GCDAsyncSocketDelegate>
@property (strong,nonatomic) GCDAsyncSocket *clientSocket;
@end

@implementation OtherSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {1,0x62};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                 dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:0];
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
-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Attention!!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //返回标准设置界面
    [self askForTreatInfomation];
    if ([segue.identifier isEqualToString:@"OtherSettingToSetting"])
    {
        Pack *pack = [[Pack alloc]init];
        [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithValue:0Xaf]] withTimeout:-1 tag:0];
    }else if ([segue.identifier isEqualToString:@"OtherSettingToMain"])
    {
        Pack *pack = [[Pack alloc]init];
        Byte addr[]={0x23,0x06};
        //设置更改生效 返回主界面
        [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addr] dataEnabled:YES data:[self dataWithValue:0xf1]] withTimeout:-1 tag:0];
        [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithValue:0XAE]]withTimeout:-1 tag:0];
    }
}
@end
