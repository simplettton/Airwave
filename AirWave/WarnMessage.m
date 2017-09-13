//
//  WarnMessage.m
//  AirWave
//
//  Created by Macmini on 2017/9/13.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "WarnMessage.h"

@implementation WarnMessage

-(NSString *)analyzeWithData:(NSData *)data
{
    NSArray *warningmsgs = @[@"",@"气囊脱落", @"气囊脱落", @"高压", @"低压", @"治疗完毕", @"气囊类型不合适", @"压力设置不合适", @"治疗过程不允许调节模式",
                            @"治疗过程不允许调节时间", @"治疗过程不允许调节顺序", @"没有连接气囊", @"选择方案与气囊不匹配", @"线控操作中",
                            @"治疗中不可切换", @"治疗过程不允许选择方案", @"无效气囊", @"连接气囊不允许调节AB顺序" ,@"测量错误" ,@"风扇异常",@"机器高温异常"];
    Byte *bytes = (Byte *)[data bytes];
    self.index = bytes[3];
    NSString *message = warningmsgs[self.index];
    return message;
}
@end
