//
//  OtherSettingViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/28.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "OtherSettingViewController.h"
#import "UIImage+ImageWithColor.h"
#import "AppDelegate.h"
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
typedef NS_ENUM(NSUInteger,typeTags)
{
    A1tag = 1, A2tag = 2, A3tag = 3, A4tag = 4, A5tag = 5,
    A6tag = 6, A7tag = 7, A8tag = 8, A9tag = 9, A10tag = 10,
    
    A11tag = 11, B1tag = 12, B2tag = 13, B3tag = 14, B4tag = 15,
     B5tag = 16, B6tag = 17, B7tag = 18, B8tag = 19, B9tag = 20
};


@interface OtherSettingViewController ()<GCDAsyncSocketDelegate>
@property (strong,nonatomic) GCDAsyncSocket *clientSocket;
@property (assign,nonatomic) NSInteger selectedATag;
@property (assign,nonatomic) NSInteger selectedBTag;
- (IBAction)onclickAport:(id)sender;
- (IBAction)onclickBport:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancelSave:(id)sender;
- (IBAction)returnToMain:(id)sender;
@end

@implementation OtherSettingViewController
{
    NSArray *typeNames;
    NSArray *typeDics;
}

////设置状态栏颜色
//- (void)setStatusBarBackgroundColor:(UIColor *)color
//{
//    
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = color;
//    }
//}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
//        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //B端与A端图片名称一样
    typeNames = [NSArray arrayWithObjects:@"",@"A1",@"A2",@"A3",@"A4",@"A5",@"A6",@"A7",@"A8",@"A9",@"A10",@"A11",
                                              @"A1",@"A2",@"A3",@"A4",@"A5",@"A6",@"A7",@"A8",@"A9", nil];
    typeDics =          @[@{@"TYPE   ":@"tag",                                 @"commit":[NSNumber numberWithUnsignedInteger:0x0]},
                          @{@"FOTA001": [NSNumber numberWithInteger:A1tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x196]},
                          @{@"LEGA003": [NSNumber numberWithInteger:A2tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x148]},
                          @{@"HNDA001": [NSNumber numberWithInteger:A3tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x198]},
                          @{@"ARMA003": [NSNumber numberWithInteger:A4tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14a]},
                          @{@"LEGA004": [NSNumber numberWithInteger:A5tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14c]},
                          @{@"ARMB004": [NSNumber numberWithInteger:A6tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14e]},
                          @{@"ABDA004": [NSNumber numberWithInteger:A7tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x156]},
                          @{@"HANA008": [NSNumber numberWithInteger:A8tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x190]},
                          @{@"NONA000": [NSNumber numberWithInteger:A9tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x150]},
                          @{@"LEGA006": [NSNumber numberWithInteger:A10tag],   @"commit":[NSNumber numberWithUnsignedInteger:0x152]},
                          @{@"LEGA008": [NSNumber numberWithInteger:A11tag],   @"commit":[NSNumber numberWithUnsignedInteger:0x153]},
                           
                          @{@"FOTB001": [NSNumber numberWithInteger:B1tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x197]},
                          @{@"LEGB003": [NSNumber numberWithInteger:B2tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x149]},
                          @{@"HNDB001": [NSNumber numberWithInteger:B3tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x199]},
                          @{@"ARMB003": [NSNumber numberWithInteger:B4tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14b]},
                          @{@"LEGB004": [NSNumber numberWithInteger:B5tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14d]},
                          @{@"ARMB004": [NSNumber numberWithInteger:B6tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x14f]},
                          @{@"ABDB004": [NSNumber numberWithInteger:B7tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x157]},
                          @{@"HANB008": [NSNumber numberWithInteger:B8tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x195]},
                          @{@"NONB000": [NSNumber numberWithInteger:B9tag],    @"commit":[NSNumber numberWithUnsignedInteger:0x151]}];
    
    NSString *aport = self.treatInfomation.aPort;
    NSString *bport = self.treatInfomation.bPort;
    for(NSDictionary *dic in typeDics)
    {
        for(NSString *key in dic)
        {
            if (![key isEqualToString:@"commit"])
            {
                if ([key isEqualToString:aport])
                {
                    NSNumber *tagNumber = [dic objectForKey:key];
                    if ([tagNumber integerValue] <= A11tag)
                    {
                        [self onclickAport:[self.view viewWithTag:[tagNumber integerValue]]];
                    }
                }
                if ([key isEqualToString:bport])
                {
                    NSNumber *tagNumber = [dic objectForKey:key];
                    if ([tagNumber integerValue] >= B1tag)
                    {
                        [self onclickBport:[self.view viewWithTag:[tagNumber integerValue]]];
                    }
                }
            }
        }
    }
    
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
    Byte dataBytes[2] = {0x62,1};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithBytes:dataBytes]]
                                                               withTimeout:-1 tag:0];
}
#pragma mark - socketDelegate
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text;
    Byte *bytes = (Byte *)[data bytes];
    
    text = [NSString stringWithFormat:@"%d",bytes[2]];
    //治疗信息
    if (bytes[2]==0x90)
    {
        [self.treatInfomation analyzeWithData:data];
    }
    
    [sock readDataWithTimeout:- 1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        NSString *title = @"保存成功，返回主界面";
        
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
                                                              handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
//                                                [self performSegueWithIdentifier:@"OtherSettingToMain" sender:nil];
                                                [self returnToMain:nil];
                                            }  );
                                        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
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
- (IBAction)onclickAport:(id)sender
{
    self.selectedATag = [sender tag];
    for (int i = A1tag; i<A11tag +1; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        //配置选中按钮
        if (btn.tag == [(UIButton *)sender tag])
        {
            [btn setImage:[UIImage imageNamed:typeNames[i]
                                    withColor:@"blue"]
                                     forState:UIControlStateNormal];
        }
        //未选中按钮
        else
        {
            [btn setImage:[UIImage imageNamed:typeNames[i]]
                 forState:UIControlStateNormal];
        }
    }

    switch (self.selectedATag)
    {
        case A1tag:
        case A3tag:     if (!(self.selectedBTag==B1tag ||self.selectedBTag == B3tag))
                        {
                            [self onclickBport:[self.view viewWithTag:B9tag]];
                            self.selectedBTag = B9tag;
                        }   break;
            
        case A2tag:
        case A4tag:     if(!(self.selectedBTag==B2tag ||self.selectedBTag == B4tag))
                        {
                            [self onclickBport:[self.view viewWithTag:B9tag]];
                            self.selectedBTag = B9tag;
                        }   break;
            
        case A5tag:
        case A6tag:
                        if(!(self.selectedBTag==B5tag ||self.selectedBTag == B6tag||self.selectedBTag == B7tag))
                        {
                            [self onclickBport:[self.view viewWithTag:B9tag]];
                            self.selectedBTag = B9tag;
                        }   break;
            
        case A7tag:     if(!(self.selectedBTag == B5tag || self.selectedBTag == B6tag))
                        {
                            [self onclickBport:[self.view viewWithTag:B9tag]];
                            self.selectedBTag = B9tag;
                        }   break;
            
        case A8tag:
        case A10tag:
        case A11tag:    [self onclickBport:[self.view viewWithTag:B9tag]];
                        self.selectedBTag = B9tag;
                        break;
            
        default:        break;
    }
}

- (IBAction)onclickBport:(id)sender
{
    self.selectedBTag = [sender tag];
    for (int i = B1tag ; i<B9tag +1; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        if (btn.tag == [(UIButton *)sender tag])
        {
            [btn setImage:[UIImage imageNamed:typeNames[i] withColor:@"blue"]
                 forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:typeNames[i]]
                 forState:UIControlStateNormal];
        }
    }
    switch (self.selectedBTag)
    {
        case B1tag:
        case B3tag:     if (!(self.selectedATag==A1tag ||self.selectedATag == A3tag))
                        {
                            [self onclickAport:[self.view viewWithTag:A9tag]];
                            self.selectedATag = A9tag;
                        }   break;
            
        case B2tag:
        case B4tag:     if(!(self.selectedATag==A2tag ||self.selectedATag == A4tag))
                        {
                            [self onclickAport:[self.view viewWithTag:A9tag]];
                            self.selectedATag = A9tag;
                        }   break;
            
        case B5tag:
        case B6tag:     if(!(self.selectedATag==A5tag ||self.selectedATag == A6tag||self.selectedATag == A7tag))
                        {
                            [self onclickAport:[self.view viewWithTag:A9tag]];
                            self.selectedATag = A9tag;
                        }   break;
            
        case B7tag:     if(!(self.selectedATag == A5tag || self.selectedATag == A6tag))
                        {
                            [self onclickAport:[self.view viewWithTag:A9tag]];
                            self.selectedATag = A9tag;
                        }   break;

        case B8tag:     [self onclickAport:[self.view viewWithTag:A9tag]];
                        self.selectedATag = A9tag;
                        break;
            
        default:        break;
    }
}

- (IBAction)save:(id)sender
{
    NSNumber *commitA;
    NSNumber *commitB;
    for(NSDictionary *dic in typeDics)
    {
        for(NSString *key in dic)
        {
            NSNumber *tagNumber = [dic objectForKey:key];
            if ([tagNumber integerValue] == self.selectedATag)
            {
                commitA = [dic objectForKey:@"commit"];
            }else if ([tagNumber integerValue] == self.selectedBTag)
            {
                commitB = [dic objectForKey:@"commit"];
                [self onclickBport:[self.view viewWithTag:[tagNumber integerValue]]];
            }
        }
    }
    Byte dataBytesA [2] = {[commitA integerValue],0};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithBytes:dataBytesA]]
                                                               withTimeout:-1   tag:1];
    Byte dataBytesB [2] = {[commitB integerValue],0};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithBytes:dataBytesB]]
                                                               withTimeout:-1   tag:1];
}
- (IBAction)cancelSave:(id)sender
{
    Byte dataBytes1 [2] = {0xba,0};
    Byte dataBytes2 [2] = {0xae,0};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithBytes:dataBytes1]] withTimeout:-1 tag:0];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithBytes:dataBytes2]] withTimeout:-1 tag:0];
//    [self performSegueWithIdentifier:@"OtherSettingToMain" sender:nil];
    [self returnToMain:nil];
}

- (IBAction)returnToMain:(id)sender
{
    [self askForTreatInfomation];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    //设置更改生效 返回主界面
    Byte dataBytes1 [2] = {0xf1,0};
    Byte dataBytes2 [2] = {0xae,0};
    Byte addrBytes [2] = {0x06,0x23};
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes] dataEnabled:YES data:[self dataWithBytes:dataBytes1]] withTimeout:-1 tag:0];
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]    dataEnabled:YES data:[self dataWithBytes:dataBytes2]] withTimeout:-1 tag:0];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //返回标准设置界面
    [self askForTreatInfomation];
    if ([segue.identifier isEqualToString:@"OtherSettingToSetting"])
    {
        Byte dataBytes [2] = {0xaf,0};
        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                               dataEnabled:YES data:[self dataWithBytes:dataBytes]]
                         withTimeout:-1   tag:0];


    }
}
@end
