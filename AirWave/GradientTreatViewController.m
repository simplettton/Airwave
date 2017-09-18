//
//  GradientTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "GradientTreatViewController.h"
#import "AppDelegate.h"
#import "Pack.h"
#import <GCDAsyncSocket.h>
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface GradientTreatViewController ()<GCDAsyncSocketDelegate>
{
    NSArray *pressGradeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    BOOL customTimeSelected;
}
@property (weak, nonatomic) IBOutlet UIPickerView *pressGradePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (IBAction)tapOtherTreatWays:(id)sender;
- (IBAction)chooseContinueTime:(id)sender;
- (IBAction)chooseCustomTime:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *continueTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *customTimeButton;
@property (strong,nonatomic)GCDAsyncSocket *clientSocket;
@end

@implementation GradientTreatViewController
- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    [self configureView];
    
    self.pressGradePicker.delegate = self;
    self.hourPicker.delegate = self;
    self.minutePicker.delegate = self;
    
    self.pressGradePicker.dataSource =self;
    self.hourPicker.dataSource = self;
    self.minutePicker.dataSource = self;
    
    

    
    pressGradeArray = @[@"自定义",@"一级",@"二级",@"三级"];
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
    if (self.treatInfomation.treatTime == 36060)
    {
        customTimeSelected = NO;
    }
    else
    {
        NSInteger pressLevel = self.treatInfomation.pressLevel;
        NSInteger hour = self.treatInfomation.treatTime / 3600;
        NSInteger minute = self.treatInfomation.treatTime / 60;
        minute = minute % 60;
        [self.pressGradePicker selectRow:pressLevel inComponent:0 animated:NO];
        [self.minutePicker selectRow:minute inComponent:0 animated:NO];
        [self.hourPicker selectRow:hour inComponent:0 animated:NO];
            
        
        //10小时取消minute的选择
        if (hour == 10)
        {
            [self pickerView:self.hourPicker didSelectRow:hour inComponent:0];
        }
        customTimeSelected = YES;
        
    }
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
    //configure navigationcontroller
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
    self.saveButton.layer.mask = maskLayer;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.cancelButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = self.cancelButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    
    //设置边框颜色

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){133.0/255.0,171.0/255.0,228.0/255.0,1});
    self.cancelButton.layer.borderColor = color;
    self.cancelButton.layer.borderWidth = 1.0f;
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.mask = maskLayer1;
}
- (IBAction)tapOtherTreatWays:(id)sender
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
    [self.continueTimeButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    
    [self.customTimeButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    
    
//    
//    Pack *pack = [[Pack alloc]init];
//
//    NSData *data = [self shortToBytes:601];
//    Byte addrBytes1[2] = {80,4};
//    NSData *addrData1 = [NSData dataWithBytes:addrBytes1 length:2];
//    
//    NSData *sendData1 = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData1 dataEnabled:YES data:data];
//    [self.clientSocket writeData:sendData1 withTimeout:-1 tag:2];
    
}

- (IBAction)chooseCustomTime:(id)sender
{
    customTimeSelected = YES;
    [self.customTimeButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    [self.continueTimeButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
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
        }else   //持续时间
        {
            minutes = 601;
        }

        Pack *pack = [[Pack alloc]init];
        
        //压力等级
        Byte addrBytes2[2] = {80,16};
        NSData *addrData2 = [NSData dataWithBytes:addrBytes2 length:2];
        
        NSInteger pressValue = [self.pressGradePicker selectedRowInComponent:0];
        Byte pressBytes [2] = {0,pressValue};
        NSData *pressData = [NSData dataWithBytes:pressBytes length:2];
        NSData *sendData2 = [pack packetWithCmdid:0X90 addressEnabled:YES addr:addrData2 dataEnabled:YES data:pressData];
        [self.clientSocket writeData:sendData2 withTimeout:-1 tag:1];
        
        //持续时间
        Byte addrBytes1[2] = {80,4};
        NSData *addrData1 = [NSData dataWithBytes:addrBytes1 length:2];
        
        NSData *data = [self shortToBytes:minutes];
        NSData *sendData1 = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData1 dataEnabled:YES data:data];
        [self.clientSocket writeData:sendData1 withTimeout:-1 tag:1];
    }
    else
    {
        [self showAlertViewWithMessage:@"网络连接已断开"];
    }
}


-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithMessage:@"保存成功"];
        });
    }
}
-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Attention"
                                                                   message:@"保存成功"
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





- (IBAction)cancel:(id)sender
{
    Pack *pack = [[Pack alloc]init];
    Byte dataBytes[2] = {0,0xba};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    
    Byte addrBytes[2] = {0,0};
    NSData *addrData = [NSData dataWithBytes:addrBytes length:2];
    
    NSData *sendData = [pack packetWithCmdid:0x90 addressEnabled:YES addr:addrData dataEnabled:YES data:data];
    [self.clientSocket writeData:sendData withTimeout:-1 tag:2];

}

#pragma mark - pickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1000)
    {
        return pressGradeArray.count;
    }
    else if(pickerView.tag == 1001)
    {
        return hourArray.count;
    }
    else
    {
        return minuteArray.count;
    }
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label  = (UILabel*)view;
    if (label == nil)
    {
        label = [[UILabel alloc]init];
        label.font= [UIFont systemFontOfSize:20];
        label.textColor = UIColorFromHex(0x2b5694);
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    if (pickerView.tag == 1000)
    {
        label.text = [pressGradeArray objectAtIndex:row];
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
-(NSData*) shortToBytes:(int)value
{

    Byte src[2]={0,0};
//    src[3] =  (Byte) ((value>>24) & 0xFF);
//    src[2] =  (Byte) ((value>>16) & 0xFF);
    //高字节在前
    src[0] =  (Byte) ((value>>8) & 0xFF);
    src[1] =  (Byte) (value & 0xFF);
    NSData *data = [NSData dataWithBytes:src length:2];
    return data;
}

@end
