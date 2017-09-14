//
//  StandardTreatViewController.m
//  AirWave
//
//  Created by Macmini on 2017/8/22.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "StandardTreatViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
const NSString *ARMA003 = @"ARMA003";
@interface StandardTreatViewController ()
{
    NSMutableArray *pressArray;
    NSArray *modeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
}
@property (strong,nonatomic)NSString *aPort;
@property (strong,nonatomic)NSString *bPort;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *minutePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pressPicker;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@end

@implementation StandardTreatViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self configureView];
    
    
    

}
- (void)viewDidLoad {

    [super viewDidLoad];
    self.aPort = self.treatInfomation.aPort;
    self.bPort = self.treatInfomation.bPort;
    self.modePicker.delegate = self;
    self.hourPicker.delegate = self;
    self.minutePicker.delegate = self;
    self.pressPicker.delegate = self;
    
    self.modePicker.dataSource = self;
    self.hourPicker.dataSource = self;
    self.minutePicker.dataSource = self;
    self.pressPicker.dataSource = self;
    
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
    [self.pressPicker selectRow:50 inComponent:0 animated:NO];
    [self.minutePicker selectRow:20 inComponent:0 animated:NO];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self judgeCellType];
}
-(void)configureView
{
//    configure navigationbar
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0X626d91)}];
    
//        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:54.0/255.0 green:100.0/255.0 blue:114.0/255.0 alpha:1];
//    
    //按钮边框
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.saveButton.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.saveButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.saveButton.layer.mask = maskLayer;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.cancelButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = self.cancelButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    self.cancelButton.layer.mask = maskLayer1;
    
    
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorSpaceRef, (CGFloat[]){133.0/255.0,171.0/255.0,228.0/255.0,1});
    self.cancelButton.layer.borderColor = color;
    self.cancelButton.layer.borderWidth = 1.0f;
    self.cancelButton.layer.masksToBounds = YES;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.buttonView.frame.size.width, 0.5f);
    topBorder.backgroundColor = UIColorFromHex(0xE4E4E4).CGColor;
    [self.buttonView.layer addSublayer:topBorder];
    
}
-(void)judgeCellType
{
    if ([self.aPort isEqualToString:@"ARMA003"] || [self.aPort isEqualToString:@"LEGA003"] || [self.bPort isEqualToString:@"ARMB003"] || [self.bPort isEqualToString:@"LEGB003"])
    {
        [self performSegueWithIdentifier:@"StandartToGradient" sender:nil];
    }
}
#pragma mark -pickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 0) {  return pressArray.count;  }
    else if (pickerView.tag == 1) {  return modeArray.count;  }
    else if (pickerView.tag == 2) {  return hourArray.count;  }
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
    if (pickerView.tag == 0){  label.text = [pressArray objectAtIndex:row];  }
    else if (pickerView.tag == 1){  label.text = [modeArray objectAtIndex:row];  }
    else if (pickerView.tag == 2){  label.text = [hourArray objectAtIndex:row ];  }
    else {  label.text = [minuteArray objectAtIndex:row];  }
    
    return label;
}
#pragma mark - segue



@end
