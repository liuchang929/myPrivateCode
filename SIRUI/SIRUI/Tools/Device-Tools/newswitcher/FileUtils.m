//
//  FileUtils.m
//  Stitcher
//
//  Created by sirui on 2017/2/20.
//  Copyright © 2017年 sirui. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

+(NSString *)docPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+(NSString *)tempPath
{
    return NSTemporaryDirectory();
}

+(NSString *)panoDir
{
    return [NSString stringWithFormat:@"%@/panoTemp", [self docPath]];
}

+(NSString *)connersPath
{
    return [NSString stringWithFormat:@"%@/conners.archive", [self panoDir]];
}

+(NSString *)sizesPath
{
    return [NSString stringWithFormat:@"%@/sizes.archive", [self panoDir]];
}

+(NSString *)warpImagePath:(size_t)index
{
    return [NSString stringWithFormat:@"%@/image_%zu.png", [self panoDir], index];
}

+(NSString *)maskImagePath:(size_t)index
{
    return [NSString stringWithFormat:@"%@/mask_%zu.png", [self panoDir], index];
}

+(NSString *)blendImagePath:(size_t)index
{
    return [NSString stringWithFormat:@"%@/blend_%zu.png", [self panoDir], index];
}

+(NSString *)panoShowingPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/panoviewer.bundle/imgs/1.jpg"];
}

@end
