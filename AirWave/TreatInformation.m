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
    
    NSLog(@"treatState=%d",self.treatState);
    
    self.treatWay = bytes[52];
    self.abFirst = bytes[69];
    self.pressLevel = bytes[70];
    self.treatMode = bytes[3];
    self.chargeSpeed = bytes[4];
    Byte treatIntervalByte[] = {bytes[13],bytes[14]};
    self.treatInterval = [self lBytesToInt:treatIntervalByte withLength:2];
    Byte keepTimeByte[] ={ bytes[15],bytes[16] };
    self.keepTime = [self lBytesToInt:keepTimeByte withLength:2];
    Byte treatTimeByte [] = { bytes[39],bytes[40],bytes[41],bytes[42] };
    self.treatTime= [self lBytesToInt:treatTimeByte withLength:4];
    
    self.aPort = [[NSMutableString alloc]initWithCapacity:20];
    self.bPort = [[NSMutableString alloc]initWithCapacity:20];
    self.enabled = [[NSMutableArray alloc]initWithCapacity:20];
    self.press = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i = 0; i < 8; i++)
    {
        NSString *aPortString = [NSString stringWithFormat:@"%c",bytes[53+i]];
        [self.aPort appendString:aPortString];
//        NSLog(@"bytes[%d] = %@",53+i,aPortString);
        NSString *bPortString = [NSString stringWithFormat:@"%c",bytes[61+i]];
        [self.bPort appendString:bPortString];
        
        NSString *enabledString = [NSString stringWithFormat:@"%d",bytes[5+i]];
        self.enabled[i] = enabledString;
        
        Byte pressBytes []= {bytes[17+i*2],bytes[18+i*2]};
        SInt16 pressInt = [self lBytesToInt:pressBytes withLength:2];
        NSString *pressString = [NSString stringWithFormat:@"%hd",pressInt];
        self.press[i] = pressString;
    }
//    NSLog(@"aport=%@",self.aPort);
    
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
