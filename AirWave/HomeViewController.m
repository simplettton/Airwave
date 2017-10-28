//
//  HomeViewController.m
//  
//
//  Created by Macmini on 2017/10/27.
//
//

#import "HomeViewController.h"
#import "AlertViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface HomeViewController ()<UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

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
- (void)viewDidLoad
{
    [super viewDidLoad];

    //presentview的蒙版
    self.shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.shadowView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.shadowView];
    self.shadowView.alpha = 0;


    self.view.layer.cornerRadius = 10;
    //navigation
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //leftBarButton
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30 , 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu-2"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barButton;
    
    //touchEnable
    self.imageView1.userInteractionEnabled = YES;
    self.imageView2.userInteractionEnabled = YES;
    UITapGestureRecognizer* firstTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBloodDev:)];
    UITapGestureRecognizer* secondTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAirWave:)];
    [self.imageView1 addGestureRecognizer:firstTapRecognizer];
    [self.imageView2 addGestureRecognizer:secondTapRecognizer];

    firstTapRecognizer.delegate = self;
    secondTapRecognizer.delegate = self;
}
-(void)leftBarButtonClicked:(UIButton *)button
{
    
}
-(void)tapBloodDev:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"-----bloodDev");
    
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
        if (airWaveSelected&&!bloodDevSelected)
        {
            self.imageView2 = nil;
            self.imageView1.image = [UIImage imageNamed:@"airwave"];
            
        }
        self.shadowView.alpha = 0;
    };
    alert.transitioningDelegate = self;
    [self presentViewController:alert animated:YES completion:nil];
}
@end
