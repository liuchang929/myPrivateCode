//
//  JEChangeLanguage.h
//  SIRUI Swift
//
//  Created by 黄雅婷 on 2019/8/22.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JEChangeLanguage : NSObject

+ (NSBundle *)bundle;//获取当前资源文件

+ (void)initUserLanguage;//初始化语言文件

+ (NSString *)userLanguage;//获取应用当前语言

+ (void)setUserLanguage:(NSString *)language;//设置当前语言

@end

NS_ASSUME_NONNULL_END
