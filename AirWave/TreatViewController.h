//
//  TreatViewController.h
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreatViewController : UIViewController

typedef void(^udpSocketBlock)(NSDictionary *dic,NSError *err);//block 用于硬件返回信息的回调

@end
