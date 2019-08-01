//
//  FileUtils.h
//  Stitcher
//
//  Created by sirui on 2017/2/20.
//  Copyright © 2017年 sirui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+(NSString *)connersPath;
+(NSString *)docPath;
+(NSString *)sizesPath;
+(NSString *)warpImagePath:(size_t)index;
+(NSString *)maskImagePath:(size_t)index;
+(NSString *)blendImagePath:(size_t)index;
+(NSString *)panoDir;
+(NSString *)panoShowingPath;
+(NSString *)tempPath;
@end
