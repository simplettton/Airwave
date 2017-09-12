//
//  ProgressView.m
//  AirWave
//
//  Created by Macmini on 2017/9/12.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ProgressView.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@implementation ProgressView

- (void)drawRect:(CGRect)rect {
    CGFloat radius = rect.size.width *0.5;
    CGPoint center = CGPointMake(radius, radius);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + 2 *M_PI*self.progress;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 5 startAngle:startAngle endAngle:endAngle clockwise:YES];
    path.lineWidth = 8;
    UIColor *lineColor = UIColorFromHex(0X65BBA9);
    [lineColor set];
    //将绘制的圆弧渲染到图层上（即显示出来）
    [path stroke];
}
-(void)setProgress:(CGFloat)progress
{

    self.progress = progress;
    //手动调用重绘方法
    [self setNeedsDisplay];
    
}


@end
