//
//  TreatRecord.m
//  
//
//  Created by Macmini on 2017/10/9.
//
//

#import "TreatRecord.h"

@implementation TreatRecord
-(TreatRecord *)analyzeWithData:(NSData *)data
{
    Byte *bytes = (Byte *)[data bytes];
    self.treatWay = bytes[4];
    Byte dutationByte[] = {bytes[6],bytes[7],bytes[8],bytes[9]};
    self.duration = [self lBytesToInt:dutationByte withLength:4];
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
