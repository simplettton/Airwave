//
//  TreatRecord.h
//  
//
//  Created by Macmini on 2017/10/9.
//
//

#import <Foundation/Foundation.h>

@interface TreatRecord : NSObject
@property (nonatomic,assign)Byte treatWay;
@property (nonatomic,assign)UInt32 duration;
@property (nonatomic,strong)NSDate *dateTime;
-(TreatRecord *)analyzeWithData:(NSData*)data;
@end
