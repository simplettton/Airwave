//
//  DetailViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/11.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImage+Rotate.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageResult;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗结果";
    UIImage *image = [UIImage imageWithData:self.record.imgData];
    _imageResult.image = [image rotate:UIImageOrientationRight];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
