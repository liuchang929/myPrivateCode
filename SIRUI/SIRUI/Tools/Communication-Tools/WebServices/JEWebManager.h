//
//  JEWebManager.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/5/31.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LoadDataCenterResult)( NSDictionary *resultDic, NSString *error);

NS_ASSUME_NONNULL_BEGIN

@interface JEWebManager : NSObject

+ (void)loadDataCenter:(NSMutableArray *)params methodName:(NSString *)methodName result:(LoadDataCenterResult)dataResult;

@end

NS_ASSUME_NONNULL_END
