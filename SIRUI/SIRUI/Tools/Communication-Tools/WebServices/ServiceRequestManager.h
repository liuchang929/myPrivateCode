//
//  NSURLConnectionManager.h
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ServiceArgs.h"

//block
typedef void (^SRMFinishBlock)();
typedef void (^SRMFailedBlock)();
typedef void (^SRMSuccessBlock)();
typedef void (^SRMSizeBlock)(long long size);
typedef void (^SRMProgressBlock)(long long total,long long size,float rate);

@interface ServiceRequestManager : NSObject<NSURLConnectionDelegate>
@property (nonatomic,retain) NSURLRequest *request;
@property (nonatomic,readonly) NSString *responseString;//请求返回字符串
@property (nonatomic,readonly) NSMutableData *responseData;//请求返回数据
@property (nonatomic,readonly) int responseStatusCode;//请求状态
@property (nonatomic,readonly) NSError *error;//请求失败
@property (nonatomic,assign) NSStringEncoding defaultResponseEncoding;//默认编码
@property(nonatomic ,copy) NSString *username;//认证请求==>用户名
@property(nonatomic ,copy) NSString *password;//认证请求==>密码

+ (id)requestWithURL:(NSURL*)url;
+ (id)requestWithRequest:(NSURLRequest*)request;
+ (id)requestWithArgs:(ServiceArgs*)args;
+ (id)requestWithName:(NSString*)methodName;//无参数的webservice请求
- (id)initWithURL:(NSURL*)url;
- (id)initWithRequest:(NSURLRequest*)request;
- (id)initWithArgs:(ServiceArgs*)args;
- (id)initWithName:(NSString*)methodName;//无参数的webservice请求
- (void)setFinishBlock:(SRMFinishBlock)aCompletionBlock;
- (void)setFailedBlock:(SRMFailedBlock)aFailedBlock;
- (void)setSuccessBlock:(SRMSuccessBlock)aSuccessBlock;//同步请求设置block
- (void)setDownloadSizeIncrementedBlock:(SRMSizeBlock)aDownloadSizeIncrementedBlock;
- (void)setProgressBlock:(SRMProgressBlock)aBytesReceivedBlock;
//真同步
- (NSString*)synchronousWithError:(NSError**)error;
//同步请求(注：伪同步，使用了gcd的异步)
- (void)startSynchronous;
//开始异步请求
- (void)startAsynchronous;
//异步简便方法
- (void)success:(SRMFinishBlock)aCompletionBlock failure:(SRMFailedBlock)aFailedBlock;
@end
