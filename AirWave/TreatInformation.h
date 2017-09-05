//
//  TreatInformation.h
//  AirWave
//
//  Created by Macmini on 2017/9/4.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreatInformation : NSObject

@property (nonatomic,assign)Byte treatState;
@property (nonatomic,assign)Byte treatWay;
@property (nonatomic,strong)NSMutableString *aPort;
@property (nonatomic,strong)NSMutableString *bPort;
@property (nonatomic,assign)Byte abFirst;
@property (nonatomic,assign)Byte pressLevel;
@property (nonatomic,assign)Byte treatMode;
@property (nonatomic,assign)Byte chargeSpeed;
@property (nonatomic,strong)NSMutableArray *enabled;
@property (nonatomic,assign)UInt16 treatInterval;
@property (nonatomic,assign)UInt16 keepTime;
@property (nonatomic,strong)NSMutableArray *press;
@property (nonatomic,assign)UInt32 treatTime;
-(TreatInformation *)analyzeWithData:(NSData*)data;
@end
