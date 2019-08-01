//
//  SRNetworking.m
//  SiRuiIOT
//
//  Created by a on 4/14/17.
//
//

#import "SRNetworking.h"

@implementation SRNetworking

+(AFHTTPSessionManager *)shareNetworking
{
    static AFHTTPSessionManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        // 客户端是否信任非法证书
        securityPolicy.allowInvalidCertificates = YES;
        // 是否在证书域字段中验证域名
        securityPolicy.validatesDomainName = NO;
        manager.securityPolicy = securityPolicy;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/json", @"application/json", @"text/javascript", @"text/html",  nil];
        
        
//        //加载证书
//        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"sirui.com" ofType:@"cer"];
//        NSData * certData =[NSData dataWithContentsOfFile:cerPath];
//        NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
//        
//        
//        //https配置
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//
//        // 允许自建证书
//        [securityPolicy setAllowInvalidCertificates:YES];
//
//
//        [securityPolicy setValidatesDomainName:NO];
//
//        // 添加证书
////        if (certData) {
////            [securityPolicy setPinnedCertificates:certSet];
////        }
//
//        manager.securityPolicy = securityPolicy;
    });
    
    return manager;
}

+(AFHTTPSessionManager *)SRHttpsRequest
{
    AFHTTPSessionManager *mgr = [self shareNetworking];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    mgr.securityPolicy = securityPolicy;
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/json", @"application/json", @"text/javascript", @"text/html",  nil];
   // mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
//    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return mgr;
}


@end
