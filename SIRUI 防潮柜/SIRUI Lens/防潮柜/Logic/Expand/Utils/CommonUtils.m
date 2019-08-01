//
//  CommonUtils.m
//  SR-Cabinet
//
//  Created by sirui on 16/10/27.
//  Copyright © 2016年 SIRUI. All rights reserved.
//

#import "CommonUtils.h"
#import "SRNetworking.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AFHTTPSingleton.h"

#define kCommonUtilsGigabyte (1024 * 1024 * 1024)//千兆字节
#define kCommonUtilsMegabyte (1024 * 1024)       //1兆字节
#define kCommonUtilsKilobyte 1024                //1千个字节

@implementation CommonUtils

//SYNTHESIZE_SINGLETON_ARC(CommonUtils);

+ (NSString *)getWifiSSID {
    NSArray *ifs = (__bridge NSArray *)(CNCopySupportedInterfaces());
  //  NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
       //NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    if (info) {
        return info[@"SSID"];
    }
    return nil;
}




+ (NSString *)getWifiBssID{
    
    
    NSArray *ifs = (__bridge NSArray *)(CNCopySupportedInterfaces());
   // NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    if (info) {
        return info[@"BSSID"];
    }
    return nil;
    
    
    
}


///parameters
+ (void)postHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure{
    

    
    AFHTTPSessionManager *manager = SRHTTPSRequst;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy = securityPolicy;
    
    
    //添加一种支持的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
    
    //内容类型
   // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
    //[manager.requestSerializer setValue:@"78912345" forHTTPHeaderField:@"token"];
    
    
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 4.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@\n%@",urlString,parameters);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];

    
}

+ (void)getHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure{
    
    
    
    AFHTTPSessionManager *manager = SRHTTPSRequst;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
//    // 客户端是否信任非法证书
//    securityPolicy.allowInvalidCertificates = YES;
//    // 是否在证书域字段中验证域名
//    securityPolicy.validatesDomainName = NO;
//    manager.securityPolicy = securityPolicy;
//    
//    
//    //添加一种支持的类型
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
//    
//    //内容类型
//    // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
//    //[manager.requestSerializer setValue:@"78912345" forHTTPHeaderField:@"token"];
//    
//    
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 4.f;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@\n%@",urlString,parameters);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
    
}




///parameters2
+ (void)postHttpWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters WithToken:(NSString *)token success:(HttpSuccess)success failure:(HttpFailure)failure{
    
    
    
    AFHTTPSessionManager *manager = SRHTTPSRequst;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy = securityPolicy;
    
    //内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    
    //    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    //    manager.requestSerializer.timeoutInterval = 4.f;
    //    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
    
}


///postjson格式参数，返回也是json格式参数
+ (void)postJsonWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(HttpSuccess)success failure:(HttpFailure)failure{


    
    AFHTTPSessionManager *manager =  SRHTTPSRequst;

    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy = securityPolicy;
    
    
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",nil];
    

        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 4.f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    

  
    
}







+ (void)postImageWithUrlString:(NSString *)urlString parameters:(NSMutableDictionary *)parameters  constructingBodyWithBlock:(HttpConstructing)constructingBodyWithBlock success:(HttpSuccess)success failure:(HttpFailure)failure{
    
    
    AFHTTPSessionManager *manager = SRHTTPSRequst;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//申明返回的结果是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];//申明请求的数据是json类型
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    manager.requestSerializer=[AFHTTPRequestSerializer serializer];

    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = YES;
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = NO;
    manager.securityPolicy = securityPolicy;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 4.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
 
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        constructingBodyWithBlock(formData);
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}







///解析"_code_"
+ (id)parserCode_key:(id)jsonData{
    
   // NSDictionary  *jsondic;
    
    if (![jsonData isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    
    id jsondic = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingMutableLeaves) error:nil];
    
    if ([jsondic isKindOfClass:[NSDictionary class]]) {
        return [jsondic valueForKey:@"_code_"];
    }
    
    //return nil;
    return @"";
    
   
    
}



///解析"_data_"
+ (id)parserData_key:(NSData *)jsonData{
    
    if (![jsonData isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    id jsondic = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingMutableLeaves) error:nil];
    
    if ([jsondic isKindOfClass:[NSDictionary class]]) {
        return [jsondic valueForKey:@"_data_"];
    }
    
    //return nil;
    return @"";
    
}


///解析物联网返回数据--------_code_返回编码含义
+ (NSString *)parserSiRuiIOTCode_keyMessage:(id)jsonData{
    
    id keyCode = [self parserCode_key:jsonData];
     NSDictionary *codeMapper = @{
                                 @0:NSLocalizedString(@"Account Success", nil),
                                 
                                 @"S001":NSLocalizedString(@"The mailbox is registered", nil),
                                 @"S000":NSLocalizedString(@"Other errors", nil),
                                 @"R000":NSLocalizedString(@"Activation successful", nil),
                                 @"R001":NSLocalizedString(@"The user is not logged in", nil),
                                 @"R002":NSLocalizedString(@"wrong user name or password", nil),
                                 @"R005":NSLocalizedString(@"Verification code error", nil),
                                 @"R006":NSLocalizedString(@"The user already exists", nil),
                                 @"R007":NSLocalizedString(@"User does not exist", nil),
                                 @"R008":NSLocalizedString(@"Unauthenticated users", nil),
                                 @"R009":NSLocalizedString(@"Verification code timed out", nil),
                                 @"R010":NSLocalizedString(@"Verification code does not allow retransmission in a short time", nil),
                                 @500:NSLocalizedString(@"Server exception", nil),
                                 @"503":NSLocalizedString(@"Request timed out", nil)};
    
    
    return [codeMapper objectForKey:keyCode];
    
    
    
}








///解析防潮柜返回数据--------_code_返回编码含义
+ (NSString *)parserCode_keyMessage:(id)jsonData{
    
    id keyCode = [self parserCode_key:jsonData];
    NSDictionary *codeMapper = @{@"0":NSLocalizedString(@"Success", nil),@"P004":NSLocalizedString(@"Time zone is missing", nil),@"P005":NSLocalizedString(@"Device number is missing", nil),@"P007":NSLocalizedString(@"Time stamp is missing", nil),@"P009":NSLocalizedString(@"Humidity is missing", nil),@"P010":NSLocalizedString(@"Page is missing", nil),@"P011":NSLocalizedString(@"Lack of opening and closing requests", nil),@"P000":NSLocalizedString(@"wrong format", nil),@"P999":NSLocalizedString(@"Parameter error or missing", nil),@"R002":NSLocalizedString(@"User name error or password error", nil),@500:NSLocalizedString(@"Server exception", nil),@"R003":NSLocalizedString(@"No equipment", nil),@"R006":NSLocalizedString(@"The data length is out of range", nil),@"604":NSLocalizedString(@"The device is not connected", nil)};
    
    
    return [codeMapper objectForKey:keyCode];
    
    
    
}



///解析防潮柜返回数据------返回json格式的字典，解析_code_对应的含义
+ (NSString *)parserCode_keyMessageWithDic:(NSDictionary *)jsonDic{
    
    NSString  * keyCode = [jsonDic valueForKey:@"_code_"];
    
    NSDictionary *codeMapper = @{@"0":NSLocalizedString(@"Success", nil),@"P004":NSLocalizedString(@"Time zone is missing", nil),@"P005":NSLocalizedString(@"Device number is missing", nil),@"P007":NSLocalizedString(@"Time stamp is missing", nil),@"P009":NSLocalizedString(@"Humidity is missing", nil),@"P010":NSLocalizedString(@"Page is missing", nil),@"P011":NSLocalizedString(@"Lack of opening and closing requests", nil),@"P000":NSLocalizedString(@"wrong format", nil),@"P999":NSLocalizedString(@"Parameter error or missing", nil),@"R002":NSLocalizedString(@"User name error or password error", nil),@500:NSLocalizedString(@"Server exception", nil),@"R003":NSLocalizedString(@"No equipment", nil),@"R006":NSLocalizedString(@"The data length is out of range", nil),@"604":NSLocalizedString(@"The device is not connected", nil)};
    
    
    return [codeMapper objectForKey:keyCode];
    
}





///解析防潮柜返回数据-------_data_返回编码含义
+ (NSString *)parserData_keyMessage:(id)jsonData{
    
    id keyCode = [self parserData_key:jsonData];
    NSDictionary *codeMapper = @{@"600":NSLocalizedString(@"DeviceSuccess", nil),@"601":NSLocalizedString(@"DeviceFail", nil),@"604":NSLocalizedString(@"Device not connected", nil)};
    
    
    return [codeMapper objectForKey:keyCode];
    
    
    
}










//统一格式下的两个时间大小比较
+(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}




+ (NSString *)getCurrentTimezone{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *date = [NSDate date];
    NSTimeInterval time = [zone secondsFromGMTForDate:date];
    NSString  *zoneStr = [NSString stringWithFormat:@"%d",(int)time/3600];
    
    return zoneStr;
}







+ (BOOL)isValidPhoneNumber:(NSString *)number {
    if (number.length != 11) {
        return NO;
    }
//    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:number];
}



+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


+ (BOOL)isValidNickName:(NSString *)name {
//    NSInteger length = [self lengthForString:name];
    NSInteger length = name.length;
    if (length < 2 || length > 8) {
        return NO;
    }
    BOOL hasNoSpace = NO;
    for (NSInteger i = 0; i < name.length; ++i) {
        unichar c = [name characterAtIndex:i];
        if (![self isValidNickNameChar:c]) {
            return NO;
        }
        if (c != 0x0020) {
            hasNoSpace = YES;
        }
    }
    if (!hasNoSpace) {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidNickNameChar:(unichar)c {
    if (0x4e00 <= c && 0x9fa5 >= c) {
        NSLog(@"Chinese");
        return YES;
    }
    if (0x0030 <= c && 0x0039 >= c) {
        NSLog(@"digital");
        return YES;
    }
    if (0x0041 <= c && 0x005a >= c) {
        NSLog(@"char ");
        return YES;
    }
    if (0x0061 <= c && 0x007a >= c) {
        NSLog(@"Capital char ");
        return YES;
    }
    if (0x0020 == c) {
        NSLog(@"space");
        return YES;
    }
    return NO;
}

+ (BOOL)hasDirtyNickNameCharWithinString:(NSString *)str {
    return YES;
}

+ (NSInteger)lengthForString:(NSString*)string {
    NSInteger len = 0;
    char* p = (char*)[string cStringUsingEncoding:NSUnicodeStringEncoding];
    NSInteger totalLen = [string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
    NSLog(@"Total: %zd", totalLen);
    for (NSInteger i = 0; i< totalLen; i++) {
        NSLog(@"char %d", *p);
        if (*p++) {
            NSLog(@"++len");
            ++len;
        }
    }
    return (len + 1) / 2;
}


+ (BOOL)isValidPassword:(NSString *)password {
    return password.length >= 6 && password.length <= 12;
}


+ (BOOL)isValidAgainPassword:(NSString *)againPassword {
    return againPassword.length >= 6 && againPassword.length <= 18;
}

+ (BOOL)isValidVerifyCode:(NSString *)verifyCode {
    if (verifyCode.length != 4) {
        return NO;
    }
    NSString *regex = @"^\\d{4}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:verifyCode];
}

//+ (BOOL)isValidLexueCode:(NSString *)lexueCode {
//    if (lexueCode.length != 7) {
//        return NO;
//    }
//    NSString *regex = @"^\\d{7}$";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    return [predicate evaluateWithObject:lexueCode];
//}

+ (BOOL)isValidPostCode:(NSString *)postCode {
    if (postCode.length != 6) {
        return NO;
    }
    NSString *regex = @"^\\d{6}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:postCode];
}


+ (NSString *)fileSizeStringFromBytes:(uint64_t)byteSize {
    if (kCommonUtilsGigabyte <= byteSize) {
        return [NSString stringWithFormat:@"%@GB", [self numberStringFromDouble:(double)byteSize / kCommonUtilsGigabyte]];
    }
    if (kCommonUtilsMegabyte <= byteSize) {
        return [NSString stringWithFormat:@"%@MB", [self numberStringFromDouble:(double)byteSize / kCommonUtilsMegabyte]];
    }
    if (kCommonUtilsKilobyte <= byteSize) {
        return [NSString stringWithFormat:@"%@KB", [self numberStringFromDouble:(double)byteSize / kCommonUtilsKilobyte]];
    }
    return [NSString stringWithFormat:@"%zdB", byteSize];
}

// output the string with max %.2f string, if the 0 got
+ (NSString *)numberStringFromDouble:(const double)num {
    NSInteger section = round((num - (NSInteger)num) * 100);
    if (section % 10) {
        return [NSString stringWithFormat:@"%.2f", num];
    }
    if (section > 0) {
        return [NSString stringWithFormat:@"%.1f", num];
    }
    return [NSString stringWithFormat:@"%.0f", num];
}

+ (CGSize)propotionScaleSize:(CGSize)originalSize withMaxSize:(CGSize)maxSize {
    CGFloat ratio = originalSize.width / maxSize.width;
    CGFloat hratio = originalSize.height / maxSize.height;
    ratio = MAX(ratio, hratio);
    if (ratio < 1.f) {
        ratio = 1.f;
    }
    CGSize size = CGSizeMake((NSInteger)(originalSize.width / ratio), (NSInteger)(originalSize.height / ratio));
    return size;
}

+ (CGSize)sizeForString:(NSString *)text forFont:(UIFont *)font {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    return size;
}

+ (BOOL)specialCharInString:(NSString *)str {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" ,.?:~`\"'[{]}|\\><"];
    NSRange range = [str rangeOfCharacterFromSet:set];
    return range.location != NSNotFound;
}

//+ (NSDictionary *)dictionaryByAppendDeviceID:(NSDictionary *)dic {
//    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:dic];
//    [result setObject:[DeviceID deviceID] forKey:@"did"];//key"did"指设备id
//    return result;
//}

//+ (NSDictionary *)dictionaryByAppendSessionID:(NSDictionary *)dic {
//    if (![[UserInfoEntity sharedInstance] hasLogedIn]) {
//        return dic;
//    }
//    
//    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:dic];
//    [result setObject:[UserInfoEntity sharedInstance].userId forKey:@"sid"];
//    return result;
//}
//
//+ (NSURL *)urlByAppendSessionID:(NSURL *)url {
//    if ([UserInfoEntity hasLogedIn]) {
//        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.f) {
//            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
//            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:@"sid" value:[UserInfoEntity sharedInstance].userId];
//            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:urlComponents.queryItems];
//            [array addObject:item];
//            urlComponents.queryItems = array;
//            url = urlComponents.URL;
//        }
//        else {
//            NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
//            NSString *sidStr = [NSString stringWithFormat:@"sid=%@", [UserInfoEntity sharedInstance].userId];
//            if (components.query.length > 0) {
//                components.query = [components.query stringByAppendingString:@"&"];
//                components.query = [components.query stringByAppendingString:sidStr];
//            }
//            else {
//                components.query = sidStr;
//            }
//            url = components.URL;
//        }
//    }
//    return url;
//}

//+ (NSString *)imageURLForImage:(ImageEntity *)image expectedSize:(CGSize)size {
//    return [self imageUrlFromURL:image.url originWidth:image.width originHeight:image.height expectedSize:size];
//}

+ (NSString *)imageUrlFromURL:(NSString *)url originWidth:(NSNumber *)width originHeight:(NSNumber *)height expectedSize:(CGSize)size {
    return url;
    /*
#warning do change the image url
    CGFloat scale = [[UIScreen mainScreen] scale];
    size = CGSizeMake(size.width * scale, size.height * scale);
    CGSize originSize = CGSizeMake(width.floatValue, height.floatValue);
    CGSize expectSize = [self propotionScaleSize:originSize withMaxSize:size];
    NSString *result = [NSString stringWithFormat:@"%@&height=%zd&width=%zd", url, (NSInteger)expectSize.height, (NSInteger)expectSize.width];
    return result;
     */
}

+ (NSString *)stringForDate:(NSDate *)date {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.locale = [NSLocale currentLocale];
    formater.dateFormat = @"yyyy年M月d日";
    return [formater stringFromDate:date];
}

+ (NSString *)stringForTimeStamp:(NSTimeInterval)ts {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:ts/1000];
    return [self stringForDate:date];
}

+ (NSString *)stringForNSDate:(NSDate *)date
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.locale = [NSLocale currentLocale];
    formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formater stringFromDate:date];
}

+ (NSDate *)dateForNSString:(NSString *)aString
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.locale = [NSLocale currentLocale];
    formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formater dateFromString:aString];
}

+ (NSDate *)dateForNSStringForGMT:(NSString *)aString
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formater.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [formater dateFromString:aString];
}

+ (NSString *)todayStringForDate:(NSDate *)aDate
{
    //    当天：采用24h制，如 20:26
    //    昨天：只显示日期“昨天”
    //    前天及更早的时间（今年）：显示月、日，如12月11日
    //    去年及更早的时间：显示年、月、日，如2012年11月5日
    //    分钟补0
    
    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:today options:0];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:aDate];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
    NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterday];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day)
    {
        formater.dateFormat = @"H:mm";
        return [formater stringFromDate:aDate];
    } else if (dateComponents.year == yesterdayComponents.year && dateComponents.month == yesterdayComponents.month && dateComponents.day == yesterdayComponents.day)
    {
        return @"昨天";
    } else if(dateComponents.year == todayComponents.year)
    {
        formater.dateFormat = @"M-d";
        return [NSString stringWithFormat:@"%ld月%ld日",dateComponents.month,dateComponents.day];
    }else
    {
        formater.dateFormat = @"yyyy-M-d";
        return [NSString stringWithFormat:@"%ld年%ld月%ld日",dateComponents.year,dateComponents.month,dateComponents.day];
    }
}


#pragma mark - String Size
+ (CGSize)caculateWithString:(NSString *)text font:(UIFont *)textFont maxSize:(CGSize)maxSize{
    CGSize size_des = CGSizeZero;
    NSDictionary *strAtt = @{NSFontAttributeName:textFont};
    CGRect rect_tmp = [text boundingRectWithSize:maxSize
                                         options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                      attributes:strAtt
                                         context:nil];
    size_des = rect_tmp.size;
    size_des = CGSizeMake(ceil(size_des.width), ceil(size_des.height));
    return size_des;
}

+ (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)createDirectoryInDocument:(NSString *)aDirectoryName
{
    NSString *path = [[CommonUtils documentDirectory] stringByAppendingPathComponent:aDirectoryName];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

#pragma mark - sw

+ (UIImage *)getImageWithSize:(CGSize)size color:(UIColor *)color{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color set];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextDrawPath(context, kCGPathFillStroke);
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
    
}


@end
