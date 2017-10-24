//
//  MyLabel.m
//  AirWave
//
//  Created by Macmini on 2017/10/24.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MyLabel.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@implementation MyLabel
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    self.layer.borderWidth = 0.8;
    self.layer.borderColor = UIColorFromHex(0xe2e2e2).CGColor;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    [super drawRect:rect];
}
@end
