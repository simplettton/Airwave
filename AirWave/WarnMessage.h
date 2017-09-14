//
//  WarnMessage.h
//  AirWave
//
//  Created by Macmini on 2017/9/13.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarnMessage : NSObject

@property (nonatomic,assign)NSInteger index;
-(NSString *)analyzeWithData:(NSData*)data;
@end
