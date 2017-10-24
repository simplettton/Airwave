//
//  HttpClient.h
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#ifndef HttpClient_h
#define HttpClient_h

#import <Foundation/Foundation.h>

@class HttpRequest;
@class HttpResponse;
@class HttpError;

typedef void (^HttpResponseObject)(HttpResponse* responseObject);
typedef void (^HttpResponseError)(HttpError* responseError);

@interface HttpClient : NSObject

+ (instancetype)instance;

- (void)post:(HttpRequest*)request
  onResponse:(HttpResponseObject)responseBlock
     onError:(HttpResponseError)errorBlock;

@end

#endif /* HttpClient_h */
