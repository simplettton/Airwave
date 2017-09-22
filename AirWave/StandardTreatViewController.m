//
//  StandardTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/22.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "StandardTreatViewController.h"
#import "AppDelegate.h"
#import <GCDAsyncSocket.h>
#import "Pack.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface StandardTreatViewController ()<GCDAsyncSocketDelegate>
{
    NSMutableArray *pressArray;
    NSArray *modeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    BOOL customTimeSelected;
}
//@property (strong,nonatomic)GCDAsyncSocket *clientSocket;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pressPicker;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *continueTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *customTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)chooseContinueTime:(id)sender;
- (IBAction)chooseCustomTime:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation StandardTreatViewController
- (void)viewDidLoad
{

    [super viewDidLoad];
    self.modePicker.delegate = self;
    self.hourPicker.delegate = self;
    self.minutePicker.delegate = self;
    self.pressPicker.delegate = self;
    
    self.modePicker.dataSource = self;
    self.hourPicker.dataSource = self;
    self.minutePicker.dataSource = self;
    self.pressPicker.dataSource = self;
    
    if (self.treatInfomation == nil)
    {
        self.treatInfomation = [[TreatInformation alloc]init];
    }
    
    pressArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i = 0; i< 241; i++) {
        [pressArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
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
    modeArray = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    [self configureView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.clientSocket = myDelegate.cclientSocket;
    NSLog(@"stadard clientsocket = %@",self.clientSocket);
    self.clientSocket.delegate = self;
    [self askForTreatInfomation];

    
}
-(void)configureView
{
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0X626d91)}];

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
    //取得治疗信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
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
        
        //保存设置前的时间和分钟
        [userDefaults setInteger:hour forKey:@"Hour"];
        [userDefaults setInteger:minute forKey:@"Minute"];
        //调到对应的时间和分钟
        [self.minutePicker selectRow:minute inComponent:0 animated:NO];
        [self.hourPicker selectRow:hour inComponent:0 animated:NO];
        
        //10小时取消minute的选择
        if (hour == 10)
        {
            [self pickerView:self.hourPicker didSelectRow:hour inComponent:0];
        }
        customTimeSelected = YES;
    }
    
    //调到对应的模式
    NSInteger mode = self.treatInfomation.treatMode;
    [self.modePicker selectRow:(mode-1) inComponent:0 animated:YES];
    
    //调到对应的压力
    NSInteger press = [self.treatInfomation.press[0] integerValue];
    [self.pressPicker selectRow:press inComponent:0 animated:YES];
    
    //保存模式和选择和压力
    [userDefaults setInteger:mode forKey:@"Mode"];
    [userDefaults setBool:customTimeSelected forKey:@"CustomTimeSelected"];
    [self configureTimeSelectButton];
    [userDefaults setInteger:press forKey:@"Press"];
    
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
    [self.backgroundView addSubview:warningImageView];
    [self.backgroundView addSubview:warningLabel];
    [warningImageView.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    [warningLabel.layer addAnimation:[self warningMessageAnimation:0.5] forKey:nil];
    // 延迟后警告消失
    int64_t delayInSeconds = 2;
    /*
     *@parameter 1,时间参照，从此刻开始计时
     *@parameter 2,延时多久，此处为秒级，还有纳秒等。10ull * NSEC_PER_MSEC
     */
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
#pragma mark - cmd

- (IBAction)cancel:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //更改前的选择
    customTimeSelected = [userDefaults boolForKey:@"CustomTimeSelected"];
    [self configureTimeSelectButton];
    
    //更改前的时间和分钟
    NSInteger hour = [userDefaults integerForKey:@"Hour"];
    NSInteger minute = [userDefaults integerForKey:@"Minute"];
    [self.hourPicker selectRow:hour inComponent:0 animated:YES];
    [self.minutePicker selectRow:minute inComponent:0 animated:YES];
    

    
    //更改前的模式
    NSInteger mode = [userDefaults integerForKey:@"Mode"];
    [self.modePicker selectRow:(mode-1) inComponent:0 animated:YES];
    
    //更改前的压力
    NSInteger press = [userDefaults integerForKey:@"Press"];
    [self.pressPicker selectRow:press inComponent:0 animated:YES];
    
    [self save:sender];
    [self showAlertViewWithMessage:@"取消更改成功"];
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
        
        
        //设置治疗时间
        Pack *pack = [[Pack alloc]init];
        Byte addrBytes[2] = {80,4};
        NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes] dataEnabled:YES data:[self dataWithValue:minutes]];
        [self.clientSocket writeData:sendData withTimeout:-1 tag:1];
        
        //设置治疗方案
        Byte addrBytes1[2] = {80,3};
        NSInteger mode = [self.modePicker selectedRowInComponent:0];
        NSData *sendData1 = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes1] dataEnabled:YES data:[self dataWithValue:(mode+1)]];

        [self.clientSocket writeData:sendData1 withTimeout:-1 tag:1];
        
        //设置治疗压力
        Byte addrByte2[2] = {80,0};
        NSInteger press= [self.pressPicker selectedRowInComponent:0];
        NSData *sendData2 = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrByte2]
                                                          dataEnabled:YES data:[self dataWithValue:press]];
        
        [self.clientSocket writeData:sendData2 withTimeout:-1 tag:1];
        
    }
    else
    {
        [self showAlertViewWithMessage:@"网络连接已断开"];
    }
}
-(void)askForTreatInfomation
{
    Pack *pack = [[Pack alloc]init];
    Byte addrBytes[2] = {0,0};
    Byte dataBytes[2] = {1,0x62};
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithBytes:addrBytes]
                                                     dataEnabled:YES data:[self dataWithBytes:dataBytes]];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:1000];
}


#pragma mark -pickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1000) {  return pressArray.count;  }
    else if (pickerView.tag == 1001) {  return modeArray.count;  }
    else if (pickerView.tag == 1002) {  return hourArray.count;  }
    else return minuteArray.count;
    
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if(label == nil)
    {
        label = [[UILabel alloc]init];
        label.font= [UIFont systemFontOfSize:20];
        label.textColor = UIColorFromHex(0x65bba9);
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    if (pickerView.tag == 1000)
    {  label.text = [pressArray objectAtIndex:row];  }
    else if (pickerView.tag == 1001)
    {  label.text = [modeArray objectAtIndex:row];  }
    else if (pickerView.tag == 1002)
    {  label.text = [hourArray objectAtIndex:row ];  }
    else {  label.text = [minuteArray objectAtIndex:row];  }
    
    return label;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1002)
    {
        if (row==(hourArray.count -1))
        {
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
        if ([segue.identifier isEqualToString: @"StandardToParameter"])
        {
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                    dataEnabled:YES data:[self dataWithValue:0x82]];
            
        }
        else if ([segue.identifier isEqualToString:@"StandardToSolution"])
        {
            NSData *switchModeData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0] dataEnabled:YES data:[self dataWithValue:0x0f]];
            [self.clientSocket writeData:switchModeData withTimeout:-1 tag:0];
            sendata = [pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                dataEnabled:YES data:[self dataWithValue:0X81]];
        }
        [self.clientSocket writeData:sendata withTimeout:-1 tag:0];
    }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureView];
        });
    }

}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        [self showAlertViewWithMessage:@"保存成功"];
    }
    if (tag == 1000)
    {
        NSLog(@"ask--------");
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

-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Attention"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              //                                                              //返回主界面
                                                              //                                                              UINavigationController *controller = [self.storyboard instantiateInitialViewController];
                                                              //                                                              [self presentViewController:controller animated:YES completion:nil];
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
