//
//  RunningTnfomation.m
//  AirWave
//
//  Created by Macmini on 2017/9/8.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RunningInfomation.h"

@implementation RunningInfomation


-(RunningInfomation *)analyzeWithData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    self.press = [[NSMutableArray alloc]initWithCapacity:20];
    self.cellState = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i = 0; i < 8; i++)
    {
        Byte pressByte[]={bytes[3+i*2],bytes[4+i*2]};
        SInt16 pressInt = [self lBytesToInt:pressByte withLength:2];
        NSString *pressString = [NSString stringWithFormat:@"%hd",pressInt];
        self.press[i] = pressString;
        
        NSString *cellStateString = [NSString stringWithFormat:@"%d",bytes[19+i]];
        self.cellState[i] = cellStateString;
        
//        NSLog(@"cellState[%d]= %@",i,cellStateString);
    }
    Byte treatProcessTimeBytes[]={bytes[27],bytes[28],bytes[29],bytes[30]};
    self.treatProcessTime = [self lBytesToInt:treatProcessTimeBytes withLength:4];
    self.curFocuse = bytes[31];
    return self;
}




//Byte数组转成int类型
-(int) lBytesToInt:(Byte[]) byte withLength:(int)length
{
    int height = 0;
    NSData * testData =[NSData dataWithBytes:byte length:length];
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
