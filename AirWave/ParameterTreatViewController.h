//
//  ParameterTreatViewController.h
//  AirWave
//
//  Created by Macmini on 2017/8/24.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatInformation.h"

@interface ParameterTreatViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property(weak,nonatomic) TreatInformation *treatInfomation;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
