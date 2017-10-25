//
//  TreatRecord.h
//  
//
//  Created by Macmini on 2017/10/9.
//
//

#import <Foundation/Foundation.h>

@interface TreatRecord : NSObject<NSCoding>

//治疗模式
@property (nonatomic,assign)Byte treatWay;
@property (nonatomic,strong)NSString *treatWayString;
//治疗方案
@property (nonatomic,assign)Byte treatMode;
//治疗时长
@property (nonatomic,assign)UInt32 duration;
@property (nonatomic,strong)NSString *durationString;
//日期与时间
@property (nonatomic,strong)NSDate *dateTime;
@property (nonatomic,strong)NSString *dateString;

@property (nonatomic,strong)NSData *imgData;
-(TreatRecord *)analyzeWithData:(NSData*)data;
@end
