//
//  AppDelegate.h
//  AirWave
//
//  Created by Macmini on 2017/8/19.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCDAsyncSocket.h>
#import <FMDB.h>
@interface AppDelegate : UIResponder
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)GCDAsyncSocket *cclientSocket;
@property (nonatomic, assign) BOOL cconnected;
@end

