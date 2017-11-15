//
//  ReportLabel.m
//  AirWave
//
//  Created by Macmini on 2017/11/15.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ReportLabel.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@implementation ReportLabel


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.layer.borderWidth = 0.8;
    self.layer.borderColor = UIColorFromHex(0x333333).CGColor;
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
@end
