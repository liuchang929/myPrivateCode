//
//  JECameraManager.m
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/25.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import "JECameraManager.h"

#define MaxLength_KB 50     //缩略图max 大小

@interface JECameraManager ()

@property (nonatomic, strong) NSString      *sandBoxPath;               //沙盒路径
@property (nonatomic, strong) NSString      *originalDirPath;           //原图图片目录路径
@property (nonatomic, strong) NSString      *thumbnailDirPath;          //缩略图图片目录路径
@property (nonatomic, strong) NSString      *videoDirPath;              //视频目录路径
@property (nonatomic, strong) NSString      *videoPreviewDirPath;       //视频预览图目录路径
@property (nonatomic, strong) NSString      *originalPath;              //原图图片路径
@property (nonatomic, strong) NSString      *thumbnailPath;             //缩略图图片路径
@property (nonatomic, strong) NSString      *lapsePointDirPath;         //延时关键点目录路径
@property (nonatomic, strong) NSString      *lapsePointPath;            //延时关键点图片路径
@property (nonatomic, strong) NSString      *videoPath;                 //视频路径
@property (nonatomic, strong) NSString      *videoPreviewPath;          //视频预览图路径
@property (nonatomic, strong) NSFileManager *fileManager;               //文件管理
@property (nonatomic, strong) NSArray       *fileList;                  //媒体数组
@property (nonatomic, strong) NSArray       *getFileList;               //需要运算的照片数组
@property (nonatomic, strong) UIImage       *getImage;                  //从相册中取到的缩略图

@property (nonatomic, strong) NSData        *originalData;              //原图图片数据
@property (nonatomic, strong) NSData        *thumbnailData;             //缩略图图片数据
@property (nonatomic, strong) NSData        *lapsePointData;            //延时关键点图片数据
@property (nonatomic, strong) NSData        *videoPreviewData;          //视频预览图图片数据

@property (nonatomic, assign) BOOL isOriginalDir;       //原图图片是否为目录
@property (nonatomic, assign) BOOL isThumbnailDir;      //缩略图是否为目录
@property (nonatomic, assign) BOOL isLapsePointDir;     //延时关键点是否为目录
@property (nonatomic, assign) BOOL isVideoDir;          //视频是否为目录
@property (nonatomic, assign) BOOL isVideoPreviewDir;   //视频预览图是否为目录

@end

@implementation JECameraManager

static JECameraManager *jeManager = nil;

+ (instancetype)shareCAMSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jeManager = [[JECameraManager alloc] init];
        
        //路径初始化
        jeManager.sandBoxPath       = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];    //沙盒目录
        jeManager.originalDirPath   = [jeManager.sandBoxPath stringByAppendingPathComponent:sOriginalPhotoSandbox];     //原图目录
        jeManager.thumbnailDirPath  = [jeManager.sandBoxPath stringByAppendingPathComponent:sThumbnailPhotoSandbox];    //缩略图目录
        jeManager.lapsePointDirPath = [jeManager.sandBoxPath stringByAppendingPathComponent:sLapsePointSandbox];        //延时关键点目录
        jeManager.videoDirPath      = [jeManager.sandBoxPath stringByAppendingPathComponent:sVideoSandbox];             //视频目录
        jeManager.videoPreviewDirPath = [jeManager.sandBoxPath stringByAppendingPathComponent:sVideoPreviewSandbox];    //视频预览图目录
        
        jeManager.fileManager       = [NSFileManager defaultManager];       //文件管理者
        
        jeManager.isOriginalDir  = NO;
        jeManager.isThumbnailDir = NO;
        jeManager.isLapsePointDir   = NO;
        jeManager.isVideoDir     = NO;
        jeManager.isVideoPreviewDir = NO;
        
    });
    
    return jeManager;
}

//获取沙盒路径
- (NSArray *)getSandBoxPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

#pragma mark - Save
/**
 将照片保存到沙盒目录中，并且同时保存一个处理过的缩略图

 @param image 需要保存的照片
 @param fileName 照片名字
 @param imageOrientation 照片方向
 @return 照片保存状态
 */
- (BOOL)saveImage:(UIImage *)image toSandboxWithFileName:(NSString *)fileName withOrientation:(UIImageOrientation)imageOrientation {
    
    NSLog(@"图片方向 : %ld", (long)imageOrientation);
    
    if (image == nil || fileName == nil) {
        return NO;
    }
    
    //创建线程池
    @autoreleasepool {
        //fileExistsAtPath判断文件或者目录是否有效 isDirectory是否是一个目录(此处我不太懂为什么初始化为否)
        BOOL isOriginalExisted = [jeManager.fileManager fileExistsAtPath:jeManager.originalDirPath isDirectory:&_isOriginalDir];
        BOOL isThumbnailExisted = [jeManager.fileManager fileExistsAtPath:jeManager.thumbnailDirPath isDirectory:&_isThumbnailDir];
        
        //目录不存在则创建一个
        if (!(jeManager.isOriginalDir && isOriginalExisted)) {
            [jeManager.fileManager createDirectoryAtPath:jeManager.originalDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (!(jeManager.isThumbnailDir && isThumbnailExisted)) {
            [jeManager.fileManager createDirectoryAtPath:jeManager.thumbnailDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //图片路径
        jeManager.originalPath = [jeManager.originalDirPath stringByAppendingPathComponent:fileName];
        jeManager.thumbnailPath = [jeManager.thumbnailDirPath stringByAppendingPathComponent:fileName];
        
        UIImage *img = [self image:image rotation:imageOrientation];
        
        
        //处理照片
        jeManager.originalData = UIImageJPEGRepresentation(img, 1.0);
        
        /*
         *  处理缩略图
         */
        //1.先压缩
        NSInteger maxLength = MaxLength_KB * 1024;
        CGFloat compression = 1.0;
        NSData *compressData = UIImageJPEGRepresentation(img, compression);
        UIImage *finalImage;
        if (compressData.length < maxLength) {
            finalImage = [UIImage imageWithData:compressData];
        }
        else {
            CGFloat max = 1.0;
            CGFloat min = 0.0;
            for (int index = 0; index < 6; ++index) {
                compression = (max + min)/2;
                compressData = UIImageJPEGRepresentation(img, compression);
                if (compressData.length < maxLength * 0.9) {
                    min = compression;
                }
                else if (compressData.length > maxLength) {
                    max = compression;
                }
                else {
                    break;
                }
            }
            //第一次对图片尺寸压缩后判断是否符合标准 (对图片尺寸压缩因为不会影响图片质量，所以会压缩到一定程度后无法再压缩)
            if (compressData.length < maxLength) {
                finalImage = [UIImage imageWithData:compressData];
            }
            else {
                //不符合标准进一步对图片质量进行压缩，一直压缩到符合要求为止
                UIImage *compressImage = [UIImage imageWithData:compressData];
                NSUInteger lastDataLength = 0;
                while (compressData.length > maxLength && compressData.length != lastDataLength) {
                    lastDataLength = compressData.length;
                    CGFloat ratio = (CGFloat)maxLength / compressData.length;
                    CGSize size = CGSizeMake((NSUInteger)(compressImage.size.width * sqrtf(ratio)), (NSUInteger)(compressImage.size.height * sqrtf(ratio)));
                    UIGraphicsBeginImageContext(size);
                    [compressImage drawInRect:CGRectMake(0, 0, size.width, size.height)];   //重新画尺寸
                    compressImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    compressData = UIImageJPEGRepresentation(compressImage, compression);
                }
                finalImage = [UIImage imageWithData:compressData];
            }
        }
        //2.再裁剪
        CGImageRef sourceImageRef = [finalImage CGImage];
        CGFloat imageWidth = finalImage.size.width * finalImage.scale;
        CGFloat imageHeight = finalImage.size.height * finalImage.scale;
        CGFloat width = imageWidth > imageHeight ? imageHeight :imageWidth; //取最短边长
        CGFloat offsetX = (imageWidth - width) / 2;
        CGFloat offsetY = (imageHeight - width) / 2;
        CGRect rect = CGRectMake(offsetX, offsetY, width, width);
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
        UIImage *cropImage = [UIImage imageWithCGImage:newImageRef];
        jeManager.thumbnailData = UIImageJPEGRepresentation(cropImage, 1.0);
        
        //将原图和缩略图都存入目录
        if ([jeManager.originalData writeToFile:jeManager.originalPath atomically:YES]) {
            if ([jeManager.thumbnailData writeToFile:jeManager.thumbnailPath atomically:YES]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SHOW_HUD_DELAY(NSLocalizedString(@"Saved", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                });
                return YES;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
                });
                return NO;
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SHOW_HUD_DELAY(NSLocalizedString(@"Failed", comment: ""),[UIApplication sharedApplication].keyWindow, HUD_SHOW_DELAY_TIME);
            });
            return NO;
        }
    }
}

//保存移动延时关键点照片
- (void)savePointImage:(UIImage *)image toPointNumber:(NSInteger)num withOrientation:(UIImageOrientation)imageOrientation {
    
    if (image == nil) {
        return;
    }
    
    @autoreleasepool {
        BOOL isLapsePointExisted = [jeManager.fileManager fileExistsAtPath:jeManager.lapsePointDirPath isDirectory:&_isLapsePointDir];
        
        if (!(jeManager.isLapsePointDir && isLapsePointExisted)) {
            [jeManager.fileManager createDirectoryAtPath:jeManager.lapsePointDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //图片路径
        jeManager.lapsePointPath = [jeManager.lapsePointDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png", (long)num]];
        
        UIImage *img = [self image:image rotation:imageOrientation];
        
        //处理图片 压缩
        NSInteger maxLength = MaxLength_KB * 1024;
        CGFloat compression = 1.0;
        NSData *compressData = UIImageJPEGRepresentation(img, compression);
        UIImage *finalImage;
        if (compressData.length < maxLength) {
            finalImage = [UIImage imageWithData:compressData];
        }
        else {
            CGFloat max = 1.0;
            CGFloat min = 0.0;
            for (int index = 0; index < 6; ++index) {
                compression = (max + min)/2;
                compressData = UIImageJPEGRepresentation(img, compression);
                if (compressData.length < maxLength * 0.9) {
                    min = compression;
                }
                else if (compressData.length > maxLength) {
                    max = compression;
                }
                else {
                    break;
                }
            }
            //第一次对图片尺寸压缩后判断是否符合标准 (对图片尺寸压缩因为不会影响图片质量，所以会压缩到一定程度后无法再压缩)
            if (compressData.length < maxLength) {
                finalImage = [UIImage imageWithData:compressData];
            }
            else {
                //不符合标准进一步对图片质量进行压缩，一直压缩到符合要求为止
                UIImage *compressImage = [UIImage imageWithData:compressData];
                NSUInteger lastDataLength = 0;
                while (compressData.length > maxLength && compressData.length != lastDataLength) {
                    lastDataLength = compressData.length;
                    CGFloat ratio = (CGFloat)maxLength / compressData.length;
                    CGSize size = CGSizeMake((NSUInteger)(compressImage.size.width * sqrtf(ratio)), (NSUInteger)(compressImage.size.height * sqrtf(ratio)));
                    UIGraphicsBeginImageContext(size);
                    [compressImage drawInRect:CGRectMake(0, 0, size.width, size.height)];   //重新画尺寸
                    compressImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    compressData = UIImageJPEGRepresentation(compressImage, compression);
                }
                finalImage = [UIImage imageWithData:compressData];
            }
        }
        jeManager.lapsePointData = UIImageJPEGRepresentation(finalImage, 1.0);
        
        //存入目录
        if ([jeManager.lapsePointData writeToFile:jeManager.lapsePointPath atomically:YES]) {
            NSLog(@"延时关键点保存成功");
        }
        else {
            NSLog(@"延时关键点保存失败");
        }
    }
}

/**
 保存视频

 @param fileName 视频名
 */
- (void)saveVideo:(NSString *)fileName {
    if (fileName == nil) {
        return;
    }
    
    @autoreleasepool {
        BOOL isVideoExisted = [jeManager.fileManager fileExistsAtPath:jeManager.videoDirPath isDirectory:&_isVideoPreviewDir];
        
        if (!(jeManager.isVideoDir && isVideoExisted)) {
            [jeManager.fileManager createDirectoryAtPath:jeManager.videoDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        jeManager.videoPath = [jeManager.videoDirPath stringByAppendingPathComponent:fileName];
    }
}

/**
 保存视频缩略图

 @param image 视频的第一帧图片
 @param fileName 视频名
 @return 是否保存成功
 */
- (BOOL)saveVideoPreview:(UIImage *)image toSandboxWithFileName:(NSString *)fileName {
    if (image == nil || fileName == nil) {
        return NO;
    }
    
    //创建线程池
    @autoreleasepool {
        BOOL isVideoPreviewExisted = [jeManager.fileManager fileExistsAtPath:jeManager.videoPreviewDirPath isDirectory:&_isVideoPreviewDir];
        
        //目录不存在就创建一个
        if (!(jeManager.isVideoPreviewDir && isVideoPreviewExisted)) {
            [jeManager.fileManager createDirectoryAtPath:jeManager.videoPreviewDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //图片路径
        jeManager.videoPreviewPath = [jeManager.videoPreviewDirPath stringByAppendingPathComponent:fileName];
        NSLog(@"缩略图的路径 = %@", _videoPreviewPath);
        
        //处理照片
        //1.先压缩
        NSInteger maxLength = MaxLength_KB * 10 * 1024;
        CGFloat compression = 1.0;
        NSData *compressData = UIImageJPEGRepresentation(image, compression);
        UIImage *finalImage;
        if (compressData.length < maxLength) {
            finalImage = [UIImage imageWithData:compressData];
        }
        else {
            CGFloat max = 1.0;
            CGFloat min = 0.0;
            for (int index = 0; index < 6; ++index) {
                compression = (max + min)/2;
                compressData = UIImageJPEGRepresentation(image, compression);
                if (compressData.length < maxLength * 0.9) {
                    min = compression;
                }
                else if (compressData.length > maxLength) {
                    max = compression;
                }
                else {
                    break;
                }
            }
            //第一次对图片尺寸压缩后判断是否符合标准 (对图片尺寸压缩因为不会影响图片质量，所以会压缩到一定程度后无法再压缩)
            if (compressData.length < maxLength) {
                finalImage = [UIImage imageWithData:compressData];
            }
            else {
                //不符合标准进一步对图片质量进行压缩，一直压缩到符合要求为止
                UIImage *compressImage = [UIImage imageWithData:compressData];
                NSUInteger lastDataLength = 0;
                while (compressData.length > maxLength && compressData.length != lastDataLength) {
                    lastDataLength = compressData.length;
                    CGFloat ratio = (CGFloat)maxLength / compressData.length;
                    CGSize size = CGSizeMake((NSUInteger)(compressImage.size.width * sqrtf(ratio)), (NSUInteger)(compressImage.size.height * sqrtf(ratio)));
                    UIGraphicsBeginImageContext(size);
                    [compressImage drawInRect:CGRectMake(0, 0, size.width, size.height)];   //重新画尺寸
                    compressImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    compressData = UIImageJPEGRepresentation(compressImage, compression);
                }
                finalImage = [UIImage imageWithData:compressData];
            }
        }
        //2.再裁剪
        /*
        CGImageRef sourceImageRef = [finalImage CGImage];
        CGFloat imageWidth = finalImage.size.width * finalImage.scale;
        CGFloat imageHeight = finalImage.size.height * finalImage.scale;
        CGFloat width = imageWidth > imageHeight ? imageHeight :imageWidth; //取最短边长
        CGFloat offsetX = (imageWidth - width) / 2;
        CGFloat offsetY = (imageHeight - width) / 2;
        CGRect rect = CGRectMake(offsetX, offsetY, width, width);
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
        UIImage *cropImage = [UIImage imageWithCGImage:newImageRef];
        */
         
        //处理图片结束的结果
        jeManager.videoPreviewData = UIImageJPEGRepresentation(finalImage, 1.0);
        
        //将其存入目录
        if ([jeManager.videoPreviewData writeToFile:jeManager.videoPreviewPath atomically:YES]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

#pragma mark - Get
/**
 取相册数组
 
 @param albumType 想要取的类型
 @return 相应类型的文件名数组，根据日期分组
 */
- (NSArray *)getAlbumArray:(AlbumType)albumType {
    NSArray *initFileList;
    
    //根据类型获取不同的数据源
    if (albumType == Photo) {
        initFileList = [[jeManager.fileManager contentsOfDirectoryAtPath:jeManager.thumbnailDirPath error:nil] pathsMatchingExtensions:@[@"png"]];
    }
    else if (albumType == Video) {
        initFileList = [[jeManager.fileManager contentsOfDirectoryAtPath:jeManager.videoDirPath error:nil] pathsMatchingExtensions:@[@"mov"]];
    }
    else if (albumType == VideoPre) {
        initFileList = [[jeManager.fileManager contentsOfDirectoryAtPath:jeManager.videoPreviewDirPath error:nil] pathsMatchingExtensions:@[@"png"]];
    }
    
    //排序
    NSArray *sequenceFileList = [initFileList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([[obj1 substringToIndex:13] integerValue] > [[obj2 substringToIndex:13] integerValue]) {
            return NSOrderedAscending;
        }
        else if ([[obj1 substringToIndex:13] integerValue] < [[obj2 substringToIndex:13] integerValue]) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    
    //分组
    NSMutableArray *groupFileList = [NSMutableArray array];
    for (int index = 0; index < sequenceFileList.count; index++) {
        if (groupFileList.count == 0) {
            NSDictionary *flashDic = @{@"Date":[[self getDateStringWithTimeStr:[sequenceFileList[index] substringToIndex:13]] substringToIndex:10], @"Array":@[sequenceFileList[index]]};
            [groupFileList addObject:flashDic];
        }
        else {
            for (int j = 0; j < groupFileList.count; j++) {
                if ([[groupFileList[j] objectForKey:@"Date"] isEqualToString:[[self getDateStringWithTimeStr:[sequenceFileList[index] substringToIndex:13]] substringToIndex:10]]) {
                    NSMutableArray *flashArray = [NSMutableArray arrayWithArray:[groupFileList[j] objectForKey:@"Array"]];
                    [flashArray addObject:sequenceFileList[index]];
                    groupFileList[j] = @{@"Date":[groupFileList[j] objectForKey:@"Date"], @"Array":flashArray};
                    break;
                }
                else {
                    if (j == (groupFileList.count - 1)) {
                        NSDictionary *flashDic = @{@"Date":[[self getDateStringWithTimeStr:[sequenceFileList[index] substringToIndex:13]] substringToIndex:10], @"Array":@[sequenceFileList[index]]};
                        [groupFileList addObject:flashDic];
                        break;
                    }
                    else {
                        continue;
                    }
                }
            }
        }
    }
    
    jeManager.fileList = groupFileList;
    
    return jeManager.fileList;
}

/**
 取某张照片

 @param imageName 需要取的照片名字
 @param album 从哪个沙盒中取
 @return 返回照片的 UIImage 格式
 */
- (UIImage *)getImage:(NSString *)imageName fromAlbumSandboxMode:(AlbumSandboxMode)album {
    
    NSString *imagePath;
    
    switch (album) {
        case Original:
        {
            imagePath = [jeManager.originalDirPath stringByAppendingPathComponent:imageName];
            
            NSLog(@"得到的路径 = %@", imagePath);
            
            jeManager.getImage = [UIImage imageWithContentsOfFile:imagePath];
        }
            break;
            
        case Thumbnail:
        {
            imagePath = [jeManager.thumbnailDirPath stringByAppendingPathComponent:imageName];
            
            jeManager.getImage = [UIImage imageWithContentsOfFile:imagePath];
        }
            break;
            
        case VideoThumbnail:
        {
            imagePath = [jeManager.videoPreviewDirPath stringByAppendingPathComponent:imageName];
            
            NSLog(@"视频缩略图的路径 = %@", imagePath);
            
            jeManager.getImage = [UIImage imageWithContentsOfFile:imagePath];
        }
            break;
            
        case LapsePoint:
        {
            imagePath = [jeManager.lapsePointDirPath stringByAppendingPathComponent:imageName];
            
            NSLog(@"得到的路径 = %@", imagePath);
            
            jeManager.getImage = [UIImage imageWithContentsOfFile:imagePath];
        }
            break;
            
        default:
            break;
    }
    
    return jeManager.getImage;
}

/**
 获取存入的视频路径

 @param videoName 需要取出来的视频的视频名
 @return 返回视频在沙盒中的路径
 */
- (NSString *)getVideoPathWithName:(NSString *)videoName {
    if (videoName) {
        @autoreleasepool {
            BOOL isVideoDirExisted = [jeManager.fileManager fileExistsAtPath:jeManager.videoDirPath isDirectory:&_isVideoDir];
            
            if (!(jeManager.isVideoDir && isVideoDirExisted)) {
                [jeManager.fileManager createDirectoryAtPath:jeManager.videoDirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            //视频路径
            jeManager.videoPath = [jeManager.videoDirPath stringByAppendingPathComponent:videoName];
        }
    }
    NSLog(@"当前视频路径 = %@", jeManager.videoPath);
    return jeManager.videoPath;
}

/**
 取视频对应的预览图

 @param fileName 需要取的预览图名
 @return 预览图的 UIImage 格式
 */
- (UIImage *)getVideoPreviewWithName:(NSString *)fileName {
    NSString *imagePath = [jeManager.videoPreviewDirPath stringByAppendingPathComponent:fileName];
    
    jeManager.getImage = [UIImage imageWithContentsOfFile:imagePath];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark - Delete
/**
 删除某张照片

 @param imageName 照片名字
 @return 是否成功删除
 */
- (BOOL)deleteImageWithName:(NSString *)imageName {
    NSString *imageOriPath = [jeManager.originalDirPath stringByAppendingPathComponent:imageName];      //原图路径
    NSString *imageThumbPath = [jeManager.thumbnailDirPath stringByAppendingPathComponent:imageName];       //缩略图路径
    BOOL imageIsOriExisted = [jeManager.fileManager fileExistsAtPath:imageOriPath];
    BOOL imageIsThumbExisted = [jeManager.fileManager fileExistsAtPath:imageThumbPath];
    
    if (imageIsOriExisted && imageIsThumbExisted) {
        [jeManager.fileManager removeItemAtPath:imageOriPath error:nil];
        [jeManager.fileManager removeItemAtPath:imageThumbPath error:nil];
        return YES;
    }
    else {
        return NO;
    }
}

/**
 删除某个视频

 @param videoName 视频名字
 @return 是否成功删除
 */
- (BOOL)deleteVideoWithName:(NSString *)videoName {
    NSString *videoOriPath = [jeManager.videoDirPath stringByAppendingPathComponent:videoName];     //原视频路径
    NSString *videoPrePath = [jeManager.videoPreviewDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [videoName substringWithRange:NSMakeRange(0, 13)]]];      //缩略图路径
    NSLog(@"videoOriPath = %@, videoPrePath = %@", videoOriPath, videoPrePath);
    BOOL videoIsOriExisted = [jeManager.fileManager fileExistsAtPath:videoOriPath];
    BOOL videoIsPreExisted = [jeManager.fileManager fileExistsAtPath:videoPrePath];
    
    NSLog(@"videoIsOriExisted = %d, videoIsPreExisted = %d", videoIsOriExisted, videoIsPreExisted);
    
    if (videoIsOriExisted || videoIsPreExisted) {
        [jeManager.fileManager removeItemAtPath:videoOriPath error:nil];
        [jeManager.fileManager removeItemAtPath:videoPrePath error:nil];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Tools
/**
 获取当前时间戳

 @return 时间戳的字符串格式
 */
- (NSString *)getNowDate {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];     //获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]*1000;    // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

/**
 将时间戳转换成标准时间格式

 @param str 时间戳的字符串格式
 @return 标准时间格式的字符串格式
 */
- (NSString *)getDateStringWithTimeStr:(NSString *)str {
    NSTimeInterval time = [str doubleValue]/1000;   //传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    //实例化一个NSDateFormatter对象
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];       //设定时间格式
    NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
    return currentDateStr;
}

/**
 图片方向矫正

 @param image 需要矫正的图片
 @param orientation 图片当前的方向
 @return 矫正后的图片
 */
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 33 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

@end
