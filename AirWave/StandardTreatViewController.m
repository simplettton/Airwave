//
//  StandardTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/22.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "StandardTreatViewController.h"
#import <SVProgressHUD.h>
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
- (IBAction)returnToMain:(id)sender;

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
    for (int i = 0; i< 241; i++)
    {
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
    
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];
    [self.hourPicker selectRow:0 inComponent:0 animated:NO];
    [self.pressPicker selectRow:100 inComponent:0 animated:NO];
    [self.modePicker selectRow:0 inComponent:0 animated:NO];
    customTimeSelected = YES;
    [self configureTimeSelectButton];
    [self updateView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xffffff);
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationItem.hidesBackButton = YES;
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0X626d91)}];
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
    self.saveButton.layer.borderWidth = 0.8;
    self.saveButton.layer.borderColor = UIColorFromHex(0x85ABE4).CGColor;
    self.cancelButton.layer.borderWidth = 0.8;
    self.cancelButton.layer.borderColor = UIColorFromHex(0x85ABE4).CGColor;
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
    
    //调到对应的压力
    NSInteger press = [self.treatInfomation.press[0] integerValue];
    [self.pressPicker selectRow:press inComponent:0 animated:YES];

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
    //添加buttoM约束
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

- (IBAction)cancel:(id)sender
{
    //默认值
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];
    [self.hourPicker selectRow:0 inComponent:0 animated:NO];
    [self.pressPicker selectRow:100 inComponent:0 animated:NO];
    [self.modePicker selectRow:0 inComponent:0 animated:NO];
    customTimeSelected = YES;
    [self configureTimeSelectButton];
    [self save:sender];
}

- (IBAction)returnToMain:(id)sender
{
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]animated:NO];
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
        
        int tag = 1;
        if ([sender isEqual:self.cancelButton]){ tag = 0; }
        
        //设置治疗时间
        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0x8004]
                                                                   dataEnabled:YES data:[self dataWithValue:minutes]] withTimeout:-1 tag:tag];

        //设置治疗方案
        NSInteger mode = [self.modePicker selectedRowInComponent:0];

        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0x8003]
                                                                   dataEnabled:YES data:[self dataWithValue:mode+1]] withTimeout:-1 tag:tag];
        
        //设置治疗压力
        NSInteger press= [self.pressPicker selectedRowInComponent:0];
        [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0x8000]
                                                                   dataEnabled:YES data:[self dataWithValue:press]] withTimeout:-1 tag:tag];
    }
    else
    {
        NSLog(@"网络连接已断开");
    }
}
-(void)askForTreatInfomation
{
    [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                               dataEnabled:YES data:[self dataWithValue:0x6201]] withTimeout:-1 tag:1000];
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

        NSData *sendata;
        if ([segue.identifier isEqualToString:@"StandardToParameter"]||[segue.identifier isEqualToString:@"StandardToSolution"])
        {

            [self.clientSocket writeData:[Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                                       dataEnabled:YES data:[self dataWithValue:0x0f]] withTimeout:-1 tag:0];
            if ([segue.identifier isEqualToString: @"StandardToParameter"])
            {
                sendata = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                        dataEnabled:YES data:[self dataWithValue:0x82]];
                
            }
            else if ([segue.identifier isEqualToString:@"StandardToSolution"])
            {
                sendata = [Pack packetWithCmdid:0x90 addressEnabled:YES addr:[self dataWithValue:0]
                                                        dataEnabled:YES data:[self dataWithValue:0x81]];
            }
            [self.clientSocket writeData:sendata withTimeout:-1 tag:0];
        }
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
            [self updateView];
        });
    }
    [sock readDataWithTimeout:- 1 tag:0];

}
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
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    AppDelegate *myDelegate =(AppDelegate *) [[UIApplication sharedApplication] delegate];
    myDelegate.cclientSocket=nil;
    myDelegate.cconnected = NO;
    NSString *wifiName = myDelegate.wifiName;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"断开连接 %@",wifiName!=nil?wifiName:@"空气波"]];
    [SVProgressHUD dismissWithDelay:0.9];

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
    src[0] = (Byte) ((value>>8) & 0xFF);
    src[1] = (Byte) (value & 0xFF);
    NSData *data = [NSData dataWithBytes:src length:2];
    return data;
}
-(NSData*) dataWithBytes:(Byte[])bytes
{
    NSData *data = [NSData dataWithBytes:bytes length:2];
    return data;
}
@end
