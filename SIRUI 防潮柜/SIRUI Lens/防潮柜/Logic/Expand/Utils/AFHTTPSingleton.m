//
//  AFHTTPSingleton.m
//  SR-Cabinet
//
//  Created by sirui on 2017/4/6.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "AFHTTPSingleton.h"

static AFHTTPSingleton * afnSingleton = nil;
@interface AFHTTPSingleton ()
@property (nonatomic,strong) AFHTTPSessionManager * sessionManager;
@end
@implementation AFHTTPSingleton

+(AFHTTPSingleton *)shareAFHTTPSingleton{
    @synchronized (self) {
        if (afnSingleton ==nil) {
            afnSingleton = [[super allocWithZone:nil] init];
            afnSingleton.sessionManager = [AFHTTPSessionManager manager];
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
            // 客户端是否信任非法证书
            securityPolicy.allowInvalidCertificates = YES;
            // 是否在证书域字段中验证域名
            securityPolicy.validatesDomainName = NO;
            afnSingleton.sessionManager.securityPolicy = securityPolicy;
        }
    }
    return afnSingleton;
}
@end
