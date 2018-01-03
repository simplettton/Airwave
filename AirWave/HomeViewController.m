//
//  HomeViewController.m
//  
//
//  Created by Macmini on 2017/10/27.
//
//
#import "HomeViewController.h"
#import "AlertViewController.h"
#import "RecordTableViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerController.h"
#import "MMdrawerVisualState.h"
#import "LeftDrawerViewController.h"
#import "AppDelegate.h"
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface HomeViewController ()<UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (assign ,nonatomic) BOOL airwaveSelected;
@property (assign ,nonatomic) BOOL bloodDevSelected;
- (IBAction)leftBarButtonClicked:(id)sender;

- (IBAction)addNewDevice:(id)sender;
@end

@implementation HomeViewController
-(instancetype)init
{
    if (self = [super init])
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //navigationController
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0XFFFFFF)}];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //presentview的蒙版
    self.shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.shadowView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.shadowView];
    self.shadowView.alpha = 0;
    
    self.view.layer.cornerRadius = 10;
    //leftBarButton
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,30, 33)];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self createNavigationLeftBarButtonItemWithCustomView:btn];
    
    //touchEnable
    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
    self.imageView1.image = [UIImage imageNamed:@"blood_dev"];
    self.imageView2.image = [UIImage imageNamed:@"airwave"];
    
    [self.imageView1 addGestureRecognizer:[self bloodDevGesture]];
    [self.imageView2 addGestureRecognizer:[self airwaveGesture]];
    self.airwaveSelected = YES;
    self.bloodDevSelected = YES;
    
    //保存默认病人信息
    
    NSArray *keys = [NSArray arrayWithObjects:@"name",@"sex",@"age",@"phoneNumber",@"address", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       @"游客",@"--",@"0",@"--",@"--", nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0;i<[keys count];i++)
    {
        if (![userDefault objectForKey:keys[i]])
        {
            [userDefault setObject:values[i] forKey:keys[i]];
            [userDefault synchronize];
        }
    }

}
//左上按钮
- (IBAction)leftBarButtonClicked:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    LeftDrawerViewController *vc = (LeftDrawerViewController  *)self.mm_drawerController.leftDrawerViewController;
    vc.headerView.nickNameLabel.text =[NSString stringWithFormat:@"%@",[userDefault objectForKey:@"name"]];
    if ([userDefault objectForKey:@"userIcon"])
    {
        UIImage *image=[UIImage imageWithData:[userDefault objectForKey:@"userIcon"]];
        vc.headerView.headerImageView.image =image;
    }

    
}
-(UITapGestureRecognizer *)airwaveGesture
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAirWave:)];
    return gesture;
}
-(UITapGestureRecognizer *)bloodDevGesture
{
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBloodDev:)];
    return gesture;
}
-(void)removeGestureRecognizerOf:(UIImageView *)view
{
    while (view.gestureRecognizers.count)
    {
        [view removeGestureRecognizer:[view.gestureRecognizers objectAtIndex:0]];
    }
}
-(void)tapBloodDev:(UITapGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"ShowBloodDev" sender:nil];
    
}
-(void)tapAirWave:(UITapGestureRecognizer *)recognizer
{
    
    [self performSegueWithIdentifier:@"ShowAirWave" sender:nil];
}
- (IBAction)addNewDevice:(id)sender
{
    self.shadowView .alpha = 0.5;
    AlertViewController *alert = [[AlertViewController alloc]init];
    
    alert.returnBlock = ^(BOOL airWaveSelected,BOOL bloodDevSelected)
    {
        [self removeGestureRecognizerOf:self.imageView1];
        [self removeGestureRecognizerOf:self.imageView2];
        
        if (airWaveSelected&&!bloodDevSelected)
        {
            self.imageView2.image = [UIImage imageNamed:@"white"];
            self.imageView1.image = [UIImage imageNamed:@"airwave"];
            [self.imageView1 addGestureRecognizer:[self airwaveGesture]];
            self.airwaveSelected = YES;
            self.bloodDevSelected =NO;
        }else if(airWaveSelected&&bloodDevSelected)
        {
            self.imageView1.image = [UIImage imageNamed:@"blood_dev"];
            [self.imageView1 addGestureRecognizer:[self bloodDevGesture]];
            self.imageView2.image = [UIImage imageNamed:@"airwave"];
            [self.imageView2 addGestureRecognizer:[self airwaveGesture]];
            self.airwaveSelected = YES;
            self.bloodDevSelected = YES;
        }else if(!airWaveSelected&&bloodDevSelected)
        {
            self.imageView1.image = [UIImage imageNamed:@"blood_dev"];
            [self.imageView1 addGestureRecognizer:[self bloodDevGesture]];
            
            self.imageView2.image = [UIImage imageNamed:@"white"];
            self.airwaveSelected = NO;
            self.bloodDevSelected = YES;
        }else if (!airWaveSelected&&!bloodDevSelected)
        {
            self.imageView1.image = [UIImage imageNamed:@"white"];
            self.imageView2.image = [UIImage imageNamed:@"white"];
            self.airwaveSelected = NO;
            self.bloodDevSelected = NO;
        }
        self.shadowView.alpha = 0;
    };
    
    alert.transitioningDelegate = self;
    alert.firstSelected = self.airwaveSelected;
    alert.secondSelected = self.bloodDevSelected;
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)createNavigationLeftBarButtonItemWithCustomView:(UIButton *)button

{
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    NSLog(@"version = %d",[version intValue]);
//    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7)
//    {
//
//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//
//        negativeSpacer.width = -5;
//
//        self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
//    }
//    else
    {
        
        self.navigationItem.leftBarButtonItem = buttonItem;
        
    }
    
}
@end
