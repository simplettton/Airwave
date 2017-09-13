//
//  BodyButton.m
//  AirWave
//
//  Created by Macmini on 2017/9/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BodyButton.h"
#import "UIImage+ImageWithColor.h"

@implementation BodyButton:UIButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)changeGreyColor
{
    NSString *imageName = [self.multiParamDic objectForKey:@"position"];
    
    if ([self.currentImage isEqual:[UIImage imageNamed:imageName withColor:@"yellow"]])
    {
        [self setImage:[UIImage imageNamed:imageName withColor:@"grey"] forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:[UIImage imageNamed:imageName withColor:@"yellow"] forState:UIControlStateNormal];
    }

}
-(void)changeGreenColor
{
    NSString *imageName = [self.multiParamDic objectForKey:@"position"];
    
    if ([self.currentImage isEqual:[UIImage imageNamed:imageName withColor:@"yellow"]]) {
        [self setImage:[UIImage imageNamed:imageName withColor:@"green"] forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:[UIImage imageNamed:imageName withColor:@"yellow"] forState:UIControlStateNormal];
    }
}
@end
