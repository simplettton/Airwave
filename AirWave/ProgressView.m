//
//  ProgressView.m
//  AirWave
//
//  Created by Macmini on 2017/9/12.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ProgressView.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface ProgressView(){
    
}
@property (nonatomic,strong)CAShapeLayer *backgroundLayer;
@end
@implementation ProgressView
{
    CGFloat lineWidth;
    CABasicAnimation *animation;
    CAShapeLayer *shapeLayer;
}
- (UILabel *)label
{
    if (_label == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        label.textAlignment = NSTextAlignmentCenter;
        label.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        //0x65BBA9
        label.textColor = UIColorFromHex(0x65BBA9);
        [self addSubview:label];
        _label = label;
    }
    return _label;
}
- (void)drawRect:(CGRect)rect {

    CGFloat radius = rect.size.width *0.5;
    CGPoint center = CGPointMake(radius, radius);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + 2 *M_PI*self.progress;
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 5 startAngle:startAngle endAngle:endAngle clockwise:YES];
    path.lineWidth = 8;
    UIColor *lineColor = UIColorFromHex(0x65BBA9);
    [lineColor setStroke];

    
    [path stroke];
    
}
- (void)drawProgress:(CGFloat )progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
