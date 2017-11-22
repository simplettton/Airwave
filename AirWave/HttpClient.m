//
//  HttpClient.m
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"

@implementation HttpClient

static HttpClient* _instance = nil;

- (void)post:(HttpRequest*)request
  onResponse:(HttpResponseObject)responseBlock
     onError:(HttpResponseError)errorBlock
{
    NSURL *url = [NSURL URLWithString: [request url]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSMutableString *params = [NSMutableString string];
    NSDictionary *paramDic = [request params];
    for (id key in paramDic)
    {
        if ([key isEqualToString:@"Img"])
        {
            //上传图片直接传数据流
            [params appendString:[paramDic objectForKey:key]];
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@=%@", key, [paramDic objectForKey:key]];
            if( [params length] > 0 )
            {
                [params appendFormat:@"&%@", str];
            }
            else
            {
                [params appendString:str];
            }
        }

    }

    [req setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:req
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if(error != nil || data.length == 0) {
                                                HttpError *httpError = [HttpError alloc];
                                                errorBlock( httpError );
                                                return;
                                            }
                                            NSHTTPURLResponse *nsHttpResponse = (NSHTTPURLResponse*)response;
                                            if( nsHttpResponse.statusCode == 500 ) {
                                                
                                                
                                                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                NSLog(@"========data%@",string);//服务器出错的堆栈
                                                NSLog(@"%@", [nsHttpResponse description]);
                                                
                                            }
                                            
                                            NSDictionary *paramDic = [request params];
                                            for (NSString *key in paramDic)
                                            {
                                                //取回记录中的图片
                                                if ([key isEqualToString:@"Id"])
                                                {
                                                    HttpResponse* httpResponse = [HttpResponse alloc];
                                                    [httpResponse setImageData:data];
                                                    responseBlock(httpResponse);
                                                }
                                            }
                                            
                                            
                                            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                            
                                            HttpResponse* httpResponse = [HttpResponse alloc];
                                            [httpResponse setJsonDist:dict];
                                            responseBlock( httpResponse );
                                        }];
    [task resume];
}

+ (instancetype)instance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

+(id)allocWithZone:(NSZone *)zone{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(_instance == nil)
        {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

@end
