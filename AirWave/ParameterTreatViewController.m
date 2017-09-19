//
//  ParameterTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/24.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ParameterTreatViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface ParameterTreatViewController ()
{
    NSArray *modeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
}
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@end

@implementation ParameterTreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    
    self.modePicker.delegate = self;
    self.hourPicker.delegate = self;
    self.minutePicker.delegate = self;
    
    self.modePicker.dataSource = self;
    self.hourPicker.dataSource = self;
    self.minutePicker.dataSource = self;
    
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
    [self.modePicker selectRow:2 inComponent:0 animated:NO];
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];

}
-(void)configureView
{
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:54.0/255.0 green:100.0/255.0 blue:114.0/255.0 alpha:1];
    
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


#pragma mark - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 0) {
        return modeArray.count;
    }else if (pickerView.tag == 1){
        return hourArray.count;
    }else return minuteArray.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = (UILabel *)view;
    if (label == nil) {
        label = [[UILabel alloc]init];
        label = [[UILabel alloc]init];
        label.font= [UIFont systemFontOfSize:20];
        label.textColor = UIColorFromHex(0x65bba9);
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    if (pickerView.tag == 0)
    {
        label.text = [modeArray objectAtIndex:row];
    }else if (pickerView.tag == 1){
        label.text = [hourArray objectAtIndex:row];
    }else{
        label.text = [minuteArray objectAtIndex:row];
    }
    return label;
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



@end
