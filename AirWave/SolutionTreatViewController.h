//
//  SolutionTreatViewController.h
//  AirWave
//
//  Created by Macmini on 2017/9/1.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatInformation.h"
@interface SolutionTreatViewController : UIViewController
@property(strong,nonatomic) TreatInformation *treatInfomation;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@end
