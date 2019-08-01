//
//  SRNetworking.h
//  SiRuiIOT
//
//  Created by a on 4/14/17.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define SRHTTPSRequst [SRNetworking SRHttpsRequest]

@interface SRNetworking : NSObject

+(AFHTTPSessionManager *)SRHttpsRequest;

@end
