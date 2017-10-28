//
//  AlertViewController.m
//  
//
//  Created by Macmini on 2017/10/27.
//
//

#import "AlertViewController.h"
#import "MyPresentViewController.h"
#import "HomeViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface AlertViewController ()<UIViewControllerTransitioningDelegate>

@property (strong ,nonatomic) UIView *shadowView;
@property (assign ,nonatomic) BOOL firstSelected;
@property (assign ,nonatomic) BOOL secondSelected;
@property (assign ,nonatomic) BOOL thirdSelected;
@end

@implementation AlertViewController

-(instancetype)init
{
    if (self = [super init])
    {
        self.modalPresentationStyle = UIModalPresentationCustom;

        self.transitioningDelegate = self;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *selectView = [UIView new];
    selectView.tag = 1000;
    selectView.frame = CGRectMake(50, 218, 275, 230);
    selectView.backgroundColor = [UIColor whiteColor];
    selectView.layer.cornerRadius = 5;
    [self.view addSubview:selectView];
    
    
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(15, 25, 210, 25);
    label.text = @"请选择要添加的设备";
    label.textColor = [UIColor colorWithRed:92.0/255 green:94.0/255 blue:102.0/255 alpha:1];
    label.font = [UIFont fontWithName:@"Arial" size:19];
    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:19];
    [selectView addSubview:label];
    
    //三个选择
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.tag = 1;
    [button1 setBackgroundImage:[UIImage imageNamed:@"airwave_selected"] forState:UIControlStateNormal];
    button1.frame = CGRectMake(40, 66, 136, 18);
    [selectView addSubview:button1];
    [button1 addTarget:self action:@selector(tapOneOption:) forControlEvents:UIControlEventTouchUpInside];
    self.firstSelected = YES;
    [self updateViewWithButton:button1];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.tag = 2;
    [button2 setBackgroundImage:[UIImage imageNamed:@"xuelou_selected"] forState:UIControlStateNormal];
    button2.frame = CGRectMake(40, 96, 136, 18);
    [selectView addSubview:button2];
    [button2 addTarget:self action:@selector(tapOneOption:) forControlEvents:UIControlEventTouchUpInside];
    self.secondSelected = YES;
    [self updateViewWithButton:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3.tag = 3;
    [button3 setBackgroundImage:[UIImage imageNamed:@"bianxie_selected"] forState:UIControlStateNormal];
    button3.frame = CGRectMake(40, 126, 136, 18);
    [selectView addSubview:button3];
    [button3 addTarget:self action:@selector(tapOneOption:) forControlEvents:UIControlEventTouchUpInside];
    self.thirdSelected = NO;
    [self updateViewWithButton:button3];
    
    
    //cancel butotn
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTintColor:UIColorFromHex(0x65bba9)];
    cancelButton.frame =  CGRectMake(27, 170, 110, 35);
    
    
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cancelButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = cancelButton.bounds;
    maskLayer.path = maskPath.CGPath;
    maskLayer.lineWidth = 1.0;
    maskLayer.strokeColor = UIColorFromHex(0x65bba9).CGColor;
    maskLayer.fillColor = nil;
    [cancelButton.layer addSublayer:maskLayer];
    [selectView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    //save button
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"确认" forState:UIControlStateNormal];
    [saveButton setTintColor:UIColorFromHex(0xFFFFFF)];
    saveButton.frame = CGRectMake(137, 170, 110, 35);
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:saveButton.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = saveButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    maskLayer1.lineWidth = 1.0;
    maskLayer1.strokeColor = UIColorFromHex(0x65bba9).CGColor;
    maskLayer1.fillColor = UIColorFromHex(0x65bba9).CGColor;
    [saveButton.layer addSublayer:maskLayer1];
    [selectView addSubview:saveButton];
    [saveButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[MyPresentViewController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
}



//返回按钮
- (void)backAction
{
    BOOL airWaveSelected;
    BOOL bloodDevSelected;
    if (self.firstSelected)
    {
        airWaveSelected = YES;
    }else
    {
        airWaveSelected = NO;
    }
    if (self.secondSelected)
    {
        bloodDevSelected = YES;
    }else{
        bloodDevSelected = NO;
    }
    
    self.returnBlock(airWaveSelected,bloodDevSelected);
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)tapOneOption:(id)sender
{
    if ([sender tag] == 1)
    {
       self.firstSelected = !self.firstSelected;
       [self updateViewWithButton:sender];
    }
    else if([sender tag] == 2)
    {
        self.secondSelected = !self.secondSelected;
        [self updateViewWithButton:sender];
    }
    else if([sender tag] == 3)
    {
        self.thirdSelected = !self.thirdSelected;
        [self updateViewWithButton:sender];
    }

}
-(void)updateViewWithButton:(UIButton *)button
{
    if ([button tag]==1)
    {
        if (!self.firstSelected)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"airwave_unselected"] forState:UIControlStateNormal];
        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"airwave_selected"] forState:UIControlStateNormal];
        }
    }else if([button tag]==2)
    {
        if (!self.secondSelected)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"xuelou_unselected"] forState:UIControlStateNormal];
        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"xuelou_selected"] forState:UIControlStateNormal];
        }
    }
    else if([button tag]==3)
    {
        if (!self.thirdSelected)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"bianxie_unselected"] forState:UIControlStateNormal];

        }
        else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"bianxie_selected"] forState:UIControlStateNormal];
        }
    }
}
@end
