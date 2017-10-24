//
//  UIImage+ImageWithColor.m
//  AirWave
//
//  Created by Macmini on 2017/9/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIImage+ImageWithColor.h"

@implementation UIImage(ImageWithColor)

+(UIImage *)imageNamed:(NSString *)name withColor:(NSString *)color
{
    UIImage *image = [[UIImage alloc]init];
    NSMutableString *imageName = [[NSMutableString alloc]initWithCapacity:20];
    if (color!=nil)
    {
        [imageName appendFormat:@"%@_%@",name,color];
    }
    else
    {
        [imageName appendFormat:@"%@",name];
    }
    image = [UIImage imageNamed:imageName];
    
    return  image;
}
@end
