//
//  ClickEffectImageView.m
//  AirWave
//
//  Created by Macmini on 2017/10/27.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ClickEffectImageView.h"

@implementation ClickEffectImageView

#pragma mark - 点击高亮处理

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.highlighted = YES;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.highlighted = NO;
}

#pragma mark - 高亮后产生的效果

- (void)setHighlighted:(BOOL)highlighted
{
    
    [super setHighlighted:highlighted];
    if (highlighted)
    {
        
        self.alpha = 0.5;
    }
    else
    {
        
        self.alpha = 1.f;
    }
}

@end
