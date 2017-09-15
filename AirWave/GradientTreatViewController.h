//
//  GradientTreatViewController.h
//  AirWave
//
//  Created by Macmini on 2017/8/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatInformation.h"

@interface GradientTreatViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property(weak,nonatomic) TreatInformation *treatInfomation;
@end
