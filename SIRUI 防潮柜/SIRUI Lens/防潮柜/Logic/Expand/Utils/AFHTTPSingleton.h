//
//  AFHTTPSingleton.h
//  SR-Cabinet
//
//  Created by sirui on 2017/4/6.
//  Copyright © 2017年 SIRUI. All rights reserved.
//

#import "AFNetworking.h"

@interface AFHTTPSingleton : AFHTTPSessionManager
+(AFHTTPSingleton *)shareAFHTTPSingleton;
@end
