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
    
    self.treatMode = bytes[5];
    
    if (self.duration)
    {
        
        int hour = _duration / 3600;
        int min = (_duration / 60)%60;
        int second = _duration % 60;
        
        //保证治疗时长为两位数
        NSString *hourString = [NSString stringWithFormat:hour>9?@"%d":@"0%d",hour];
        NSString *minString = [NSString stringWithFormat:min>9?@"%d":@"0%d",min];
        NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
        
        
        self.durationString = [NSString stringWithFormat:@"%@:%@:%@",hourString,minString,secondString];
        NSLog(@"duration = %@",_durationString);
    }
    else
    {
        self.durationString = [NSString stringWithFormat:@"00:00:00"];
    }
    self.dateTime = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateString = [fmt stringFromDate:self.dateTime];
    NSLog(@"date = %@",self.dateString);
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
