//
//  StandardTreatViewController.h
//  AirWave
//
//  Created by Macmini on 2017/8/22.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCDAsyncSocket.h>
#import "TreatInformation.h"

@interface StandardTreatViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property(strong,nonatomic) TreatInformation *treatInfomation;
@property(strong,nonatomic) GCDAsyncSocket *clientSocket;
@end
