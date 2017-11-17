//
//  HttpHelper.m
//  demo
//
//  Created by Macmini on 2017/10/23.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "HttpHelper.h"
#import "HttpClient.h"
#import "HttpRequest.h"
#import "HttpResponse.h"
#import "HttpError.h"
static NSString * SERVERIP_KEY = @"ServerIp";
@implementation HttpHelper
{
    NSString *_token;
    NSString *_userid;
}

static HttpHelper * _instance = nil;
//static NSString * BASE_URL = @"http://192.168.2.127/demo/index.php?";
//static NSString * BASE_URL = @"http://218.17.22.131:3088/demo/index.php?";
static NSString * TOKEN_KEY = @"GGCToken";
static NSString * USERID_KEY = @"GGCUserId";

- (NSString *)md5:(NSString*)input
{
    const char *cStr = [input UTF8String];//转换成utf-8
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result);
    
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [Mstr appendFormat:@"%02X", result[i]];
    }
    return [Mstr lowercaseString];
}

-(bool)isLogin
{
    if( _token == nil )
    {
        return NO;
    }
    return YES;
}

-(void)login:(NSString*)email
    password:(NSString*)password
  onResponse:(HttpResponseObject)responseBlock
     onError:(HttpResponseError)errorBlock
{
    NSString *md5Passwd = [self md5:password];
    
    // append parameter
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:email forKey:@"email"];
    [params setValue:md5Passwd forKey:@"password"];
    
    [self post:@"user/login" params:params hasToken:NO
    onResponse:^(HttpResponse *responseObject) {
        NSDictionary* jsonDict = [responseObject jsonDist];
        
        int status = [[jsonDict objectForKey:@"status"] intValue];
        if( status == 0 )
        {
            _token = [[jsonDict objectForKey:@"data"] objectForKey:@"access_token"];
            _userid = [[[jsonDict objectForKey:@"data"] objectForKey:@"userid"]stringValue];
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:_token forKey:TOKEN_KEY];
            [userDefault setObject:_userid forKey:USERID_KEY];
            [userDefault synchronize];
        }
        responseBlock(responseObject);
    }
       onError:^(HttpError *responseError) {
           errorBlock(responseError);
       }];
}

-(void)logout
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:TOKEN_KEY];
    [userDefault removeObjectForKey:USERID_KEY];
    [userDefault synchronize];
}

-(void)post:(NSString*)apiName
     params:(NSDictionary*)params
   hasToken:(bool)hasToken
 onResponse:(HttpResponseObject)responseBlock
    onError:(HttpResponseError)errorBlock
{
    HttpRequest *request = [HttpRequest alloc];
    
    if( hasToken )
    {
        NSString *ts = [NSString stringWithFormat:@"%ld", time(NULL)];
        NSString *token = [self md5:[NSString stringWithFormat:@"%@%@%@", _token, _userid, ts]];
        
        [params setValue:_userid forKey:@"userid"];
        [params setValue:ts forKey:@"timestamp"];
        [params setValue:token forKey:@"token"];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *serverIp = [userDefault objectForKey:SERVERIP_KEY];
    NSString *baseUrl = [NSString stringWithFormat:@"%@/demo/index.php?",serverIp];
    NSString *url = [NSString stringWithFormat:@"%@action=%@", baseUrl, apiName];
    [request setUrl:url];
    [request setParams:params];
    
    [[HttpClient instance] post:request
                     onResponse:^(HttpResponse *responseObject) {
                         responseBlock(responseObject);
                     }
                        onError:^(HttpError *responseError) {
//                            errorBlock(responseError);
                        }];
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[userDefault objectForKey:TOKEN_KEY]);
    _token = [userDefault objectForKey:TOKEN_KEY];
    _userid = [userDefault objectForKey:USERID_KEY] ;
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
