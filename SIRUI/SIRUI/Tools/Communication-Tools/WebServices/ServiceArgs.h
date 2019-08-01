//
//  ServiceArgs.h
//  CommonLibrary
//
//  Created by aJia on 13/2/20.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import <Foundation/Foundation.h>
//请求方式(ServiceHttpSoap1与ServiceHttpSoap12的区别在于请求头不一样)
typedef enum{
    ServiceHttpGet=0,
    ServiceHttpPost=1,
    ServiceHttpSoap1=2,
    ServiceHttpSoap12=3
}ServiceHttpWay;

@interface ServiceArgs : NSObject
@property(nonatomic,readonly) NSURLRequest *request;
@property(nonatomic,readonly) NSURL *webURL;
@property(nonatomic,readonly) NSString *defaultSoapMesage;
@property(nonatomic,assign)   ServiceHttpWay httpWay;//请求方式,默认为ServiceHttpSoap12请求
@property(nonatomic,assign)   NSTimeInterval timeOutSeconds;//请求超时时间,默认60秒
@property(nonatomic,assign)   NSStringEncoding defaultEncoding;//默认编辑
@property(nonatomic,copy)     NSString *serviceURL;//webservice访问地址
@property(nonatomic,copy)     NSString *serviceNameSpace;//webservice命名空间
@property(nonatomic,copy)     NSString *methodName;//调用的方法名 
@property(nonatomic,copy)     NSString *bodyMessage;//请求字符串
@property(nonatomic,copy)     NSString *soapHeader;//有认证的请求头设置
@property(nonatomic,retain)   NSDictionary *headers;//请求头
@property(nonatomic,retain)   NSArray *soapParams;//方法参数设置

+(ServiceArgs*)serviceMethodName:(NSString*)methodName;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName soapMessage:(NSString*)soapMsg;
//webservice访问设置
+(void)setNameSapce:(NSString*)space;
+(void)setWebServiceURL:(NSString*)url;
@end
