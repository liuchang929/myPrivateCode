//
//  ServiceOperation.h
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/7.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceArgs.h"
@interface ServiceOperation : NSOperation{
    // In concurrent operations, we have to manage the operation's state
    BOOL executing_;
    BOOL finished_;
    
    // The actual NSURLConnection management
    NSURLConnection*  connection_;
    NSMutableData*    data_;
    int statusCode_;
    NSString *responStr_;
}
@property (nonatomic,retain) NSDictionary* userInfo;
@property (nonatomic,retain) NSURLRequest* request;
@property (nonatomic,readonly) NSError* error;
@property (nonatomic,readonly) int responseStatusCode;//请求状态
@property (nonatomic,readonly) NSString *responseString;
@property (nonatomic,readonly) NSMutableData *responseData;
@property (nonatomic,assign) NSStringEncoding defaultResponseEncoding;//默认编码
@property(nonatomic ,copy) NSString *username;
@property(nonatomic ,copy) NSString *password;//用户认证请求

- (id)initWithURL:(NSURL*)url;
- (id)initWithRequest:(NSURLRequest*)request;
- (id)initWithArgs:(ServiceArgs*)args;
- (id)initWithMethodName:(NSString*)name;
@end
