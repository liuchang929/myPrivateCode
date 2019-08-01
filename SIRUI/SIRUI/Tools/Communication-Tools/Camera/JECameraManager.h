//
//  JECameraManager.h
//  SIRUI
//
//  Created by 黄雅婷 on 2019/4/25.
//  Copyright © 2019 JennyT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

NS_ASSUME_NONNULL_BEGIN

//沙盒相册类型
typedef enum albumSandboxMode {
    Original,       //原图
    Thumbnail,      //缩略图
    VideoThumbnail, //视频缩略图
    LapsePoint      //延时关键点
}AlbumSandboxMode;

typedef enum albumType {
    Photo,      //照片
    Video,      //视频
    VideoPre,   //视频缩略图
}AlbumType;

@interface JECameraManager : NSObject

@property (nonatomic, assign) AlbumSandboxMode albumSandboxMode;  //沙盒相册类型
@property (nonatomic, assign) AlbumType        albumType;         //相册类型

//单例
+ (instancetype)shareCAMSingleton;

//保存图片
- (BOOL)saveImage:(UIImage *)image toSandboxWithFileName:(NSString *)fileName withOrientation:(UIImageOrientation)imageOrientation;

//保存视频预览图
- (BOOL)saveVideoPreview:(UIImage *)image toSandboxWithFileName:(NSString *)fileName;

//取相册数据数组
- (NSArray *)getAlbumArray:(AlbumType)albumType;

//从哪个相册中取哪张照片
- (UIImage *)getImage:(NSString *)imageName fromAlbumSandboxMode:(AlbumSandboxMode)album;

//获取视频路径
- (NSString *)getVideoPathWithName:(NSString *)videoName;

//取某个视频的预览图
- (UIImage *)getVideoPreviewWithName:(NSString *)fileName;

//删除某张照片
- (BOOL)deleteImageWithName:(NSString *)imageName;

//删除某个视频
- (BOOL)deleteVideoWithName:(NSString *)videoName;

//获取沙盒路径
- (NSArray *)getSandBoxPath;

//获取当前时间戳
- (NSString *)getNowDate;

//将时间戳转换成标准时间格式
- (NSString *)getDateStringWithTimeStr:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
