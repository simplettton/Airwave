//
//  HttpHelper.h
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#ifndef HttpHelper_h
#define HttpHelper_h

#import <Foundation/Foundation.h>
#import "HttpClient.h"

@interface HttpHelper : NSObject

+ (instancetype)instance;

-(bool)isLogin;

-(void)login:(NSString*)email
    password:(NSString*)password
  onResponse:(HttpResponseObject)responseBlock
     onError:(HttpResponseError)errorBlock;

-(void)logout;

-(void)post:(NSString*)apiName
     params:(NSDictionary*)params
   hasToken:(bool)hasToken
 onResponse:(HttpResponseObject)responseBlock
    onError:(HttpResponseError)errorBlock;

@end

#endif /* HttpHelper_h */
