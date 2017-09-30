//
//  ParameterTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/24.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ParameterTreatViewController.h"
#import "AppDelegate.h"
#import "Pack.h"
#import <GCDAsyncSocket.h>
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface ParameterTreatViewController ()<GCDAsyncSocketDelegate>
{
    NSArray *modeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    BOOL customTimeSelected;
}
@property (strong,nonatomic)GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *continueTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *customTimeButton;
- (IBAction)tapGradientTreat:(id)sender;
- (IBAction)chooseContinueTime:(id)sender;
- (IBAction)chooseCustomTime:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@end

@implementation ParameterTreatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modePicker.delegate = self;
    self.hourPicker.delegate = self;
    self.minutePicker.delegate = self;
    
    self.modePicker.dataSource = self;
    self.hourPicker.dataSource = self;
    self.minutePicker.dataSource = self;
    
    if (self.treatInfomation == nil)
    {
        self.treatInfomation = [[TreatInformation alloc]init];
    }
    
    modeArray = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    hourArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i =0; i<11; i++)
    {
        [hourArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    minuteArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i=0; i<60; i++)
    {
        [minuteArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //默认的设置
    [self.hourPicker selectRow:0 inComponent:0 animated:NO];
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];
    [self.modePicker selectRow:0 inComponent:0 animated:NO];
    customTimeSelected = YES;
    [self configureTimeSelectButton];
    [self configureView];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.clientSocket = myDelegate.cclientSocket;
    self.clientSocket.delegate = self;
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    [self askForTreatInfomation];
}

-(void)configureView
{

    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x626d91)}];

    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
    
    
    //设置单边圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.saveButton.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.saveButton.bounds;
    maskLayer.path = maskPath.CGPath;
    maskLayer.lineWidth = 1.0;
    maskLayer.strokeColor = UIColorFromHex(0x85ABE4).CGColor;
    maskLayer.fillColor = UIColorFromHex(0x85ABE4).CGColor;
    [self.saveButton.layer addSublayer:maskLayer];
    
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.cancelButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = self.cancelButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    maskLayer1.lineWidth = 1.0;
    maskLayer1.strokeColor = UIColorFromHex(0x85ABE4).CGColor;
    maskLayer1.fillColor = nil;
    [self.cancelButton.layer addSublayer:maskLayer1];
}
-(void)updateView
{

    //持续时间
    if (self.treatInfomation.treatTime == 36060)
    {
        customTimeSelected = NO;
        
    }
    else        //自定义时间
    {
        
        NSInteger hour = self.treatInfomation.treatTime / 3600;
        NSInteger minute = self.treatInfomation.treatTime / 60;
        minute = minute % 60;
        
        //调到对应的时间和分钟
        [self.minutePicker selectRow:minute inComponent:0 animated:YES];
        [self.hourPicker selectRow:hour inComponent:0 animated:YES];
        
        //10小时取消minute的选择
        if (hour == 10)
        {
            [self pickerView:self.hourPicker didSelectRow:hour inComponent:0];
        }
        customTimeSelected = YES;
    }
        [self configureTimeSelectButton];
    
    //调到对应的模式
    NSInteger mode = self.treatInfomation.treatMode;
    [self.modePicker selectRow:(mode-1) inComponent:0 animated:YES];
    
}
-(void)configureTimeSelectButton
{
    if (customTimeSelected)
    {
        [self.customTimeButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        [self.continueTimeButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        if ([self.backgroundView viewWithTag:888]!=nil)
        {
            [[self.backgroundView viewWithTag:888]removeFromSuperview];
        }
    }
    else
    {
        [self.continueTimeButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        [self.customTimeButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        if ([self.backgroundView viewWithTag:888]==nil)
        {
            UIView *maskView = [[UIView alloc]initWithFrame:CGRectMake(172, 192, 195, 234)];
            maskView.backgroundColor = [UIColor whiteColor];
            maskView.alpha = 0.7;
            maskView.tag = 888;
            [self.backgroundView addSubview:maskView];
        }
    }
}

-(IBAction)tapGradientTreat:(id)sender
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
- (IBAction)chooseContinueTime:(id)sender
{
    customTimeSelected = NO;
    [self configureTimeSelectButton];
}

- (IBAction)chooseCustomTime:(id)sender
{
    customTimeSelected = YES;
    [self configureTimeSelectButton];
    
}
- (IBAction)save:(id)sender
{
    if (self.clientSocket != nil)
    {
        NSInteger minutes;
        //自定义时间
        if (customTimeSelected== YES)
        {
            
            NSString *hour = hourArray[[self.hourPicker selectedRowInComponent:0]];
            NSString *minute = minuteArray[[self.minutePicker selectedRowInComponent:0]];
            minutes = [hour integerValue]*60 + [minute integerValue];;
        }
        else   //持续时间
        {
            minutes = 601;
        }
        
        Pack *pack = [[Pack alloc]init];
        //取消不弹框
        int tag = 1;
        if ([sender isEqual:self.cancelButton])
        {
            tag =0;
        }
        //设置时间
        Byte addrBytes1[2] = {80,4};
        [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes1] dataEnabled:YES data:[self dataWithValue:minutes]] withTimeout:-1 tag:tag];
        
        //设置治疗方案
        Byte addrBytes2[2] = {80,3};
        NSInteger mode = [self.modePicker selectedRowInComponent:0];
        [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes2]dataEnabled:YES data:[self dataWithValue:(mode+1)]] withTimeout:-1 tag:tag];
    }
    else
    {
        [self showAlertViewWithMessage:@"网络连接已断开"];
    }
}
- (IBAction)cancel:(id)sender

{
    [self.hourPicker selectRow:0 inComponent:0 animated:NO];
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];
    [self.modePicker selectRow:0 inComponent:0 animated:NO];
    customTimeSelected = YES;
    [self configureTimeSelectButton];
    [self save:sender];
}
-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte dataBytes[2] = {1,0x62};
    [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithBytes:dataBytes]] withTimeout:-1 tag:1000];
}

#pragma mark - socketDelegate
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithMessage:@"保存成功"];
        });
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
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cconnected = NO;
    [self presentDisconnectAlert];
}
-(void)presentDisconnectAlert
{
    UIView *disconnectView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, 375, 557)];
    disconnectView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(93, 150, 190, 30)];
    label.text = [NSString stringWithFormat:@"ohno！网络连接断开了~"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(122, 230, 130, 30);
    button.backgroundColor = UIColorFromHex(0x65BBA9);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"重新连接"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(returnToMain) forControlEvents:UIControlEventTouchUpInside];
    [disconnectView addSubview:label];
    [disconnectView addSubview:button];
    [self.view addSubview:disconnectView];
}
#pragma mark - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1000)
    {
        return modeArray.count;
    }
    else if (pickerView.tag == 1001)
    {
        return hourArray.count;
    }else return minuteArray.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (label == nil)
    {
        label = [[UILabel alloc]init];
        label = [[UILabel alloc]init];
        label.font= [UIFont systemFontOfSize:20];
        label.textColor = UIColorFromHex(0x65bba9);
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    if (pickerView.tag == 1000)
    {
        label.text = [modeArray objectAtIndex:row];
    }
    else if (pickerView.tag == 1001)
    {
        label.text = [hourArray objectAtIndex:row];
    }
    else
    {
        label.text = [minuteArray objectAtIndex:row];
    }
    return label;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //hour选择器
    if (pickerView.tag == 1001)
    {
        
        if (row == (hourArray.count -1))
        {
            //十小时则不显示分
            minuteArray = [NSMutableArray arrayWithObject:@"0"];
            [self.minutePicker reloadAllComponents];
        }
        else
        {
            minuteArray = [[NSMutableArray alloc]initWithCapacity:20];
            for (int i=0; i<60; i++)
            {
                [minuteArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
            [self.minutePicker reloadAllComponents];
        }
    }
}
#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (segue.identifier !=nil)
    {
        Pack *pack = [[Pack alloc]init];
        NSData *sendata;
        if ([segue.identifier isEqualToString: @"ParameterToStandard"])
        {
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                dataEnabled:YES data:[self dataWithValue:0x0d]];
            
        }
        else if ([segue.identifier isEqualToString:@"ParameterToSolution"])
        {
            [self.clientSocket writeData:[pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                                       dataEnabled:YES data:[self dataWithValue:0x0f]] withTimeout:-1 tag:0];
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                dataEnabled:YES data:[self dataWithValue:0X81]];
        }
        [self.clientSocket writeData:sendata withTimeout:-1 tag:0];
    }
}
-(void)returnToMain
{
    [self performSegueWithIdentifier:@"ParameterToMain" sender:nil];
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
-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Attention!!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
