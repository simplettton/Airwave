//
//  ProgressView.h
//  AirWave
//
//  Created by Macmini on 2017/9/12.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (nonatomic,strong)UIColor *circleColor;
@property (nonatomic,assign)CGFloat lineWith;
@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,strong)UILabel *label;
- (void)drawProgress:(CGFloat )progress;

@end
