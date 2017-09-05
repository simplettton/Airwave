//
//  TreatInformation.m
//  AirWave
//
//  Created by Macmini on 2017/9/4.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TreatInformation.h"

@implementation TreatInformation
-(TreatInformation *)analyzeWithData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    self.treatState = bytes[51];
    self.treatWay = bytes[52];
    self.abFirst = bytes[69];
    self.pressLevel = bytes[70];
    self.treatMode = bytes[3];
    self.chargeSpeed = bytes[4];
    
    
    return self;
}

//Byte数组转成int类型
-(int) lBytesToInt:(Byte[]) byte
{
    int height = 0;
    NSData * testData =[NSData dataWithBytes:byte length:4];
    for (int i = 0; i < [testData length]; i++)
    {
        if (byte[[testData length]-i] >= 0)
        {
            height = height + byte[[testData length]-i];
        } else
        {
            height = height + 256 + byte[[testData length]-i];
        }
        height = height * 256;
    }
    if (byte[0] >= 0)
    {
        height = height + byte[0];
    } else {
        height = height + 256 + byte[0];
    }
    return height;
}
@end
