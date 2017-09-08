//
//  RunningInfomation.h
//  AirWave
//
//  Created by Macmini on 2017/9/8.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunningInfomation : NSObject
@property (nonatomic,strong)NSMutableArray *press;
@property (nonatomic,strong)NSMutableArray *cellState;
@property (nonatomic,assign)UInt32 treatProcessTime;
@property (nonatomic,assign)Byte curFocuse;
-(RunningInfomation *)analyzeWithData:(NSData*)data;
@end
