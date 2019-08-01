//
//  CommonUtils.h
//  SR-Cabinet
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

typedef void (^HttpSuccess)(id data);
typedef void (^HttpFailure)(NSError *error);
typedef void (^HttpConstructing)(id<AFMultipartFormData>formData);
@interface CommonUtils : NSObject



+ (NSString *)getWifiSSID;
+ (NSString *)getWifiBssID;



+ (void)getHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure;

+ (void)postHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure;


+ (void)postHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters WithToken:(NSString *)token success:(HttpSuccess)success failure:(HttpFailure)failure;



+ (void)postJsonWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure;




+ (void)postImageWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters  constructingBodyWithBlock:(HttpConstructing)constructingBodyWithBlock success:(HttpSuccess)success failure:(HttpFailure)failure;



+ (id)parserCode_key:(id)jsonData;
+ (id)parserData_key:(id)jsonData;

///
+ (NSString *)parserSiRuiIOTCode_keyMessage:(id)jsonData;

+ (NSString *)parserCode_keyMessage:(id)jsonData;
+ (NSString *)parserData_keyMessage:(id)jsonData;

+ (NSString *)parserCode_keyMessageWithDic:(NSDictionary *)jsonDic;



+(int)compareDate:(NSString*)date01 withDate:(NSString*)date02;


+ (BOOL)isValidPhoneNumber:(NSString *)number;


+ (BOOL)isValidateEmail:(NSString *)email;

+ (BOOL)isValidNickName:(NSString *)name;

+ (BOOL)isValidPassword:(NSString *)password;

+ (BOOL)isValidAgainPassword:(NSString *)againPassword;

+ (BOOL)isValidVerifyCode:(NSString *)verifyCode;
+ (BOOL)isValidPostCode:(NSString *)postCode;//邮编格式是否错误
+ (NSString *)getCurrentTimezone;//获取当前时间



//用来测试中文的长度
+ (NSInteger)lengthForString:(NSString*)string;

//文件的大小转换成KB / MB / GB等等
+ (NSString *)fileSizeStringFromBytes:(uint64_t)byteSize;

+ (CGSize)propotionScaleSize:(CGSize)originalSize withMaxSize:(CGSize)maxSize;

+ (CGSize)sizeForString:(NSString *)text forFont:(UIFont *)font;

// 字符串是否包含特殊字符
+ (BOOL)specialCharInString:(NSString *)str;

//#pragma mark - Network related 
//+ (NSDictionary *)dictionaryByAppendDeviceID:(NSDictionary *)dic;
//
//+ (NSDictionary *)dictionaryByAppendSessionID:(NSDictionary *)dic;
//
//+ (NSURL *)urlByAppendSessionID:(NSURL *)url;

#pragma mark - image url
+ (NSString *)imageUrlFromURL:(NSString *)url originWidth:(NSNumber *)width originHeight:(NSNumber *)height expectedSize:(CGSize)size;
//+ (NSString *)imageURLForImage:(ImageEntity *)image expectedSize:(CGSize)size;

// 时间/时间戳转换为字符串
+ (NSString *)stringForDate:(NSDate *)date;
+ (NSString *)stringForTimeStamp:(NSTimeInterval)ts;
+ (NSString *)todayStringForDate:(NSDate *)aDate;
+ (NSString *)stringForNSDate:(NSDate *)date;
+ (NSDate *)dateForNSString:(NSString *)aString;
+ (NSDate *)dateForNSStringForGMT:(NSString *)aString;

@end
