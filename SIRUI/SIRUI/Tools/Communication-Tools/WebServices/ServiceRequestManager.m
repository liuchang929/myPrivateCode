//
//  NSURLConnectionManager.m
//  IOSWebservices
//
//  Created by aJia on 2014/2/18.
//  Copyright (c) 2014年 rang. All rights reserved.
//

#import "ServiceRequestManager.h"

@interface ServiceRequestManager (){

    NSMutableData *responseData_;
    int statusCode_;
    NSError *error_;
}
@property (readwrite, nonatomic, copy) SRMFinishBlock finishBlock;
@property (readwrite, nonatomic, copy) SRMFailedBlock failedBlock;
@property (readwrite, nonatomic, copy) SRMSuccessBlock successBlock;
@property (readwrite, nonatomic, copy) SRMSizeBlock sizeBlock;
@property (readwrite, nonatomic, copy) SRMProgressBlock progressBlock;
@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,assign) long long totalFileSize;
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
- (void)clearAndDelegate;
- (void)parseStringEncodingFromHeaders:(NSDictionary*)responseHeaders;
- (void)parseMimeType:(NSString **)mimeType andResponseEncoding:(NSStringEncoding *)stringEncoding fromContentType:(NSString *)contentType;
@end

@implementation ServiceRequestManager
@synthesize responseData=responseData_;
@synthesize responseStatusCode=statusCode_;
@synthesize error=error_;
-(void)dealloc{
    
    if (self.connection) {
        [self.connection cancel];
        [self.connection release],self.connection=nil;
    }
    if (responseData_) {
         [responseData_ release],responseData_=nil;
    }
   
    if (error_) {
        [error_ release],error_=nil;
    }
	[super dealloc];
}
+ (id)requestWithRequest:(NSURLRequest*)request{
    return [[[self alloc] initWithRequest:request] autorelease];
}
+ (id)requestWithArgs:(ServiceArgs*)args{
    return [[[self alloc] initWithArgs:args] autorelease];
}
+ (id)requestWithName:(NSString *)methodName{
    return [[[self alloc] initWithName:methodName] autorelease];
}
+ (id)requestWithURL:(NSURL*)url{
    return [[[self alloc] initWithURL:url] autorelease];
}
- (id)init{
    if (self=[super init]) {
        error_=nil;
        statusCode_=123;
        self.defaultResponseEncoding=NSUTF8StringEncoding;
        responseData_=[[NSMutableData data] retain];
    }
    return self;
}
- (id)initWithRequest:(NSURLRequest*)request{
    self=[self init];
    self.request=request;
    return self;
}
- (id)initWithArgs:(ServiceArgs*)args{
    return [self initWithRequest:[args request]];
}
- (id)initWithURL:(NSURL*)url{
    return [self initWithRequest:[NSURLRequest requestWithURL:url]];
}
- (id)initWithName:(NSString*)name{
    return [self initWithArgs:[ServiceArgs serviceMethodName:name]];
}
- (NSString*)responseString{
    if (responseData_&&[responseData_ length]>0) {
       return [[[NSString alloc] initWithBytes:[responseData_ bytes] length:[responseData_ length] encoding:self.defaultResponseEncoding] autorelease];
    }
    return @"";
}
- (void)setFinishBlock:(SRMFinishBlock)afinishBlock{
    if (_finishBlock!=afinishBlock) {
        [_finishBlock release];
        _finishBlock=[afinishBlock copy];
    }
}
- (void)setFailedBlock:(SRMFailedBlock)afailedBlock{
    if (_failedBlock!=afailedBlock) {
        [_failedBlock release];
        _failedBlock=[afailedBlock copy];
    }
}
- (void)setSuccessBlock:(SRMSuccessBlock)asuccessBlock{
    if (_successBlock!=asuccessBlock) {
        [_successBlock release];
        _successBlock=[asuccessBlock copy];
    }
}
- (void)setDownloadSizeIncrementedBlock:(SRMSizeBlock)aDownloadSizeIncrementedBlock
{
    if (_sizeBlock!=aDownloadSizeIncrementedBlock) {
        [_sizeBlock release];
        _sizeBlock=[aDownloadSizeIncrementedBlock copy];
    }
}
- (void)setProgressBlock:(SRMProgressBlock)aprogressBlock{
    if (_progressBlock!=aprogressBlock) {
        [_progressBlock release];
        _progressBlock=[aprogressBlock copy];
    }
}
- (void)startAsynchronous{
    if (self.request) {
        [self clearAndDelegate];//取消前一次请求
        self.connection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.connection start];
        [self showNetworkActivityIndicator];
    }
}
- (void)startSynchronous{
    [responseData_ setLength:0];
    if (self.request) {
        [self clearAndDelegate];//取消前一次请求
        [self showNetworkActivityIndicator];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSHTTPURLResponse *response=nil;
            NSError *error=nil;
            NSData *data=[NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
            [self parseStringEncodingFromHeaders:[response allHeaderFields]];//编码处理
            statusCode_=(int)[response statusCode];
            error_=[error retain];
            //请求完成
            if (statusCode_!=200) {
                [responseData_ release],responseData_=nil;
                
                NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode_];
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
                error_ = [[NSError alloc] initWithDomain:@"ServiceRequestManager"
                                                    code:statusCode_
                                                userInfo:userInfo];
            }else{
                [responseData_ appendData:data];
            }
            [self hideNetworkActivityIndicator];
            if (self.successBlock) {
                self.successBlock();
            }
        });
    }
}
- (NSString*)synchronousWithError:(NSError**)err{
    [responseData_ setLength:0];
    if (self.request) {
        [self clearAndDelegate];//取消前一次请求
        [self showNetworkActivityIndicator];
        
        NSHTTPURLResponse *response=nil;
        NSError *error=nil;
        NSData *data=[NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
        [self parseStringEncodingFromHeaders:[response allHeaderFields]];//编码处理
        statusCode_=(int)[response statusCode];
        error_=[error retain];
        //请求完成
        if (statusCode_!=200) {
            [responseData_ release],responseData_=nil;
            
            NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode_];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
            error_ = [[NSError alloc] initWithDomain:@"ServiceRequestManager"
                                                code:statusCode_
                                            userInfo:userInfo];
        }else{
            [responseData_ appendData:data];
        }
        [self hideNetworkActivityIndicator];
    }
    *err=error_;
    return [self responseString];
}
- (void)success:(SRMFinishBlock)aCompletionBlock failure:(SRMFailedBlock)aFailedBlock{
    [self setFinishBlock:aCompletionBlock];
    [self setFailedBlock:aFailedBlock];
    [self startAsynchronous];
}
#pragma mark -
#pragma mark NSURLConnection delegate Methods
- (void)connection:(NSURLConnection *)con didReceiveResponse:(NSURLResponse *)response {
    // store data
    [responseData_ setLength:0];      //通常在这里先清空接受数据的缓存
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    [self parseStringEncodingFromHeaders:[httpResponse allHeaderFields]];//编码处理
    statusCode_=(int)[httpResponse statusCode];
    
    if (self.sizeBlock) {
        self.sizeBlock([response expectedContentLength]);
    }
    
    if(statusCode_ == 200 ) {
        //取得文件大小
        self.totalFileSize=[response expectedContentLength];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode_];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"ServiceRequestManager"
                                            code:statusCode_
                                        userInfo:userInfo];
        [responseData_ release],responseData_=nil;
        [self clearAndDelegate];//取消请求
        [self hideNetworkActivityIndicator];
        if (self.failedBlock) {
            self.failedBlock();
        }
    }
    
}

- (void)connection:(NSURLConnection *)con didReceiveData:(NSData *)data {
    [responseData_ appendData:data];    //可能多次收到数据，把新的数据添加在现有数据最后
    if (self.progressBlock) {
        long long proValue=[responseData_ length]*1.0;
        self.progressBlock(self.totalFileSize,[responseData_ length]*1.0,proValue/self.totalFileSize);
    }
}
- (void)connection:(NSURLConnection *)con
  didFailWithError:(NSError *)error
{
    [self hideNetworkActivityIndicator];
    error_=[error retain];
    [responseData_ release];
    responseData_ = nil;
    if (self.failedBlock) {
        self.failedBlock();
    }
    [self clearAndDelegate];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)con
{
    [self hideNetworkActivityIndicator];
   
    if(self.finishBlock)
    {
        self.finishBlock();
    }
    [self clearAndDelegate];
}
//身份认证
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if ([self.request.URL.absoluteString hasPrefix:@"https"]) {
        return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    }
    return NO;
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    /***
    if (!self.username || !self.password) {
        [[challenge sender] useCredential:nil forAuthenticationChallenge:challenge];
        return;
    }
     ***/
    
    if (self.username&&self.password&&[self.username length]>0&&[self.password length]>0) {
        NSURLCredential *cred = [[[NSURLCredential alloc] initWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone] autorelease];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    }else{
        if ([self.request.URL.absoluteString hasPrefix:@"https"]) {
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
                
                [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
                
                [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
                
            }
        }
    }
}
#pragma mark -private Methods
- (void)clearAndDelegate{
    if (self.connection) {
        [self.connection cancel];
        [self.connection release],self.connection=nil;
    }
}
- (void)showNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)hideNetworkActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)parseStringEncodingFromHeaders:(NSDictionary*)responseHeaders
{
	// Handle response text encoding
	NSStringEncoding charset = 0;
	NSString *mimeType = nil;
	[self parseMimeType:&mimeType andResponseEncoding:&charset fromContentType:[responseHeaders valueForKey:@"Content-Type"]];
	if (charset != 0) {
		[self setDefaultResponseEncoding:charset];
	}
}
- (void)parseMimeType:(NSString **)mimeType andResponseEncoding:(NSStringEncoding *)stringEncoding fromContentType:(NSString *)contentType
{
	if (!contentType) {
		return;
	}
	NSScanner *charsetScanner = [NSScanner scannerWithString: contentType];
	if (![charsetScanner scanUpToString:@";" intoString:mimeType] || [charsetScanner scanLocation] == [contentType length]) {
		*mimeType = [contentType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		return;
	}
	*mimeType = [*mimeType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString *charsetSeparator = @"charset=";
	NSString *IANAEncoding = nil;
    
	if ([charsetScanner scanUpToString: charsetSeparator intoString: NULL] && [charsetScanner scanLocation] < [contentType length]) {
		[charsetScanner setScanLocation: [charsetScanner scanLocation] + [charsetSeparator length]];
		[charsetScanner scanUpToString: @";" intoString: &IANAEncoding];
	}
    
	if (IANAEncoding) {
		CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)IANAEncoding);
		if (cfEncoding != kCFStringEncodingInvalidId) {
			*stringEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
		}
	}
}
@end
