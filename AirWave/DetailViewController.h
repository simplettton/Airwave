//
//  DetailViewController.h
//  AirWave
//
//  Created by Macmini on 2017/10/11.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatRecord.h"
@interface DetailViewController : UIViewController
@property (nonatomic,strong)TreatRecord *record;
@property (nonatomic,strong)NSDictionary *dic;
@end
