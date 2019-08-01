//
//  ServiceOperation.m
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/7.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ServiceOperation.h"

@interface ServiceOperation ()
- (void)parseStringEncodingFromHeaders:(NSDictionary*)responseHeaders;
- (void)parseMimeType:(NSString **)mimeType andResponseEncoding:(NSStringEncoding *)stringEncoding fromContentType:(NSString *)contentType;
@end

@implementation ServiceOperation
@synthesize error = error_, responseData = data_,responseStatusCode=statusCode_;
#pragma mark -
#pragma mark Initialization & Memory Management
- (void)dealloc
{
    if( connection_ ) {
        [connection_ cancel]; [connection_ release]; connection_ = nil;
    }
    
    [data_ release];
    data_ = nil;
    
    [error_ release];
    error_ = nil;
    if (responStr_) {
        [responStr_ release],responStr_=nil;
    }
    
    [super dealloc];
}
- (id)init{
    if (self=[super init]) {
        self.defaultResponseEncoding=NSUTF8StringEncoding;
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
- (id)initWithMethodName:(NSString*)name{
    return [self initWithArgs:[ServiceArgs serviceMethodName:name]];
}
- (id)initWithURL:(NSURL *)url
{
    self=[self init];
    self.request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    self.defaultResponseEncoding=NSISOLatin1StringEncoding;
    return self;
}
- (NSString*)responseString{
    if (data_&&[data_ length]>0) {
       return [[[NSString alloc] initWithBytes:[data_ bytes] length:[data_ length] encoding:self.defaultResponseEncoding] autorelease];
    }
    return @"";
}
#pragma mark -
#pragma mark Start & Utility Methods

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    if( connection_ ) {
        [connection_ cancel];
        [connection_ release];
        connection_ = nil;
    }
    
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}
-(void)canceled {
	// Code for being cancelled
    error_ = [[NSError alloc] initWithDomain:@"ServiceOperation"
                                        code:123
                                    userInfo:nil];
	statusCode_=123;
    [self done];
	
}
- (void)start
{
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Ensure that the operation should exute
    if( finished_ || [self isCancelled] ) { [self done]; return; }
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    [self willChangeValueForKey:@"isExecuting"];
    executing_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    connection_ = [[NSURLConnection alloc] initWithRequest:self.request
                                                  delegate:self];
    
    //connection_ = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:connectionURL_ cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0] delegate:self];
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing_;
}

- (BOOL)isFinished
{
    return finished_;
}

#pragma mark -
#pragma mark Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
	else {
		[data_ release];
		data_ = nil;
		error_ = [error retain];
		[self done];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
    
    [data_ appendData:data];
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    [self parseStringEncodingFromHeaders:[httpResponse allHeaderFields]];//编码处理
    NSInteger statusCode = [httpResponse statusCode];
    statusCode_=(int)statusCode;
    if( statusCode == 200 ) {
        NSUInteger contentSize = [httpResponse expectedContentLength] > 0 ? [httpResponse expectedContentLength] : 0;
        data_ = [[NSMutableData alloc] initWithCapacity:contentSize];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"ServiceOperation"
                                            code:statusCode
                                        userInfo:userInfo];
        [self done];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
	else {
		[self done];
	}
}
//身份认证
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (!self.username || !self.password) {
        [[challenge sender] useCredential:nil forAuthenticationChallenge:challenge];
        return;
    }
    NSURLCredential *cred = [[[NSURLCredential alloc] initWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone] autorelease];
    [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}
#pragma mark private Methods
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
