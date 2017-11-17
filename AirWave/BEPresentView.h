//
//  BEPresentView.h
//  AirWave
//
//  Created by Macmini on 2017/11/16.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BEPresentViewHight 350.0
@interface BEPresentView : UIView
//展示从底部向上弹出的UIView（包含遮罩）
@property (strong ,nonatomic) UIView *contentView;
- (void)showInView:(UIView *)view;
- (void)disMissView;
@end
