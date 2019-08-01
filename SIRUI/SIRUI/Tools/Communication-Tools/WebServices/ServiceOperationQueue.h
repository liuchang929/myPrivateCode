//
//  ServiceQueue.h
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/11.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceOperation.h"
//block
typedef void (^SOQFinishBlock)(ServiceOperation *operation);
typedef void (^SOQCompleteBlock)();

@interface ServiceOperationQueue : NSOperationQueue{
   BOOL finished_;
   NSMutableArray *items_;
   NSInteger operTotal_;
}
@property (nonatomic,assign) BOOL showNetworkActivityIndicator;//是否在状态栏显示网络请求中
@property (nonatomic,readonly) NSArray *items;//保存请求完成后的线程
- (void)setFinishBlock:(SOQFinishBlock)afinishBlock;//其中一个请求完成后执行
- (void)setCompleteBlock:(SOQCompleteBlock)acompleteBlock;//所有请求完成
- (void)reset;//重置
@end
