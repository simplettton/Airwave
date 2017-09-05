//
//  UIColor+UIcolor_RGB.h
//  AirWave
//
//  Created by Macmini on 2017/8/28.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(UIColor_RGB)
// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+(UIColor *)colorWithHexString:(NSString *)color;
@end
