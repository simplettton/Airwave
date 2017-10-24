//
//  HttpRequest.h
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#ifndef HttpRequest_h
#define HttpRequest_h

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject

@property NSString *url;
@property NSDictionary *params;

@end

#endif /* HttpRequest_h */

