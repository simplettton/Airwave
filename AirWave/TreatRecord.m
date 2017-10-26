//
//  TreatRecord.m
//  
//
//  Created by Macmini on 2017/10/9.
//
//

#import "TreatRecord.h"

@implementation TreatRecord
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.idString forKey:@"idString"];
    [aCoder encodeInteger:self.treatWay forKey:@"treatWay"];
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
    [aCoder encodeObject:self.durationString forKey:@"durationString"];
    
    [aCoder encodeObject:self.imagePath forKey:@"imagePath"];
//    [aCoder encodeObject:self.imgData forKey:@"imgData"];
    [aCoder encodeBool:self.hasImage forKey:@"hasImage"];
    
    [aCoder encodeObject:self.treatWayString forKey:@"treatWayString"];

    [aCoder encodeObject:self.dateTime forKey:@"dateTime"];
    [aCoder encodeInt:self.duration forKey:@"duration"];
    
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.idString = [aDecoder decodeObjectForKey:@"idString"];
        self.treatWay = [aDecoder decodeIntegerForKey:@"treatWay"];
        self.dateString = [aDecoder decodeObjectForKey:@"dateString"];
        self.durationString = [aDecoder decodeObjectForKey:@"durationString"];
        
        self.imagePath= [aDecoder decodeObjectForKey:@"imagePath"];
//        self.imgData = [aDecoder decodeObjectForKey:@"imgData"];
        self.hasImage = [aDecoder decodeBoolForKey:@"hasImage"];
        
        self.treatWayString = [aDecoder decodeObjectForKey:@"treatWayString"];
        
        self.dateTime = [aDecoder decodeObjectForKey:@"dateTime"];
        self.duration = [aDecoder decodeIntForKey:@"duration"];
    }
    return self;
}
-(instancetype)init
{
    if(self = [super init])
    {
        self.hasImage = NO;
        NSString *number = [[NSString alloc]init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (![userDefaults objectForKey:@"idString"])
        {
            self.idString = @"0";
            [userDefaults setObject:self.idString forKey:@"idString"];
        }
        else
        {
            number = [userDefaults objectForKey:@"idString"];
            self.idString =[NSString stringWithFormat:@"%ld",[number integerValue]+1];
            [userDefaults setObject:self.idString forKey:@"idString"];
        }
    }
    return self;
}
-(TreatRecord *)analyzeWithData:(NSData *)data
{
    
    Byte *bytes = (Byte *)[data bytes];
    
    self.treatMode = bytes[5];
    if (self.treatWay)
    {
        switch (self.treatWay)
        {
            case 1:
                self.treatWayString = @"标准治疗";
                break;
            case 2:
                self.treatWayString = @"梯度治疗";
                break;
            case 3:
                self.treatWayString = @"参数治疗";
                break;
            case 4:
                self.treatWayString = @"方案治疗";
                break;
            default:
                self.treatWayString = @"标准治疗";
                break;
        }
    }
    else
    {
        self.treatWayString = @"治疗方式";
    }
    if (self.duration)
    {
        int hour = _duration / 3600;
        int min = (_duration / 60)%60;
        int second = _duration % 60;
        
        //治疗时间为两位数
        NSString *hourString = [NSString stringWithFormat:hour>9?@"%d":@"0%d",hour];
        NSString *minString = [NSString stringWithFormat:min>9?@"%d":@"0%d",min];
        NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
        self.durationString = @"";
        if (hour>0)
        {
            self.durationString = [self.durationString stringByAppendingString:[NSString stringWithFormat:@"%@小时",hourString]];
        }
        if (min>0)
        {
            self.durationString = [self.durationString stringByAppendingString:[NSString stringWithFormat:@"%@分钟",minString]];
        }
        if (second>0)
        {
            self.durationString = [self.durationString stringByAppendingString:[NSString stringWithFormat:@"%@秒",secondString]];
        }
        
//        self.durationString = [NSString stringWithFormat:@"%@:%@:%@",hourString,minString,secondString];
    }
    else
    {
        self.durationString = [NSString stringWithFormat:@"00:00:00"];
    }
    self.dateTime = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateString = [fmt stringFromDate:self.dateTime];
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
    } else
    {
        height = height + 256 + byte[0];
    }
    return height;
}

@end
